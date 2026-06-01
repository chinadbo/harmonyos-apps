import relationalStore from '@ohos.data.relationalStore'
import common from '@ohos.app.ability.common'
import DatabaseHelper from './DatabaseHelper'
import { Template, TemplateItem, createTemplateRow } from '../model/Template'
import { Item } from '../model/Item'
import ItemDao from './ItemDao'

export default class TemplateDao {
  private static tableName: string = 'templates'

  static async ensureBuiltinTemplates(context: common.Context): Promise<void> {
    const store = await DatabaseHelper.getInstance().getStore(context)
    const countSet = await store.querySql('SELECT COUNT(id) AS total_count FROM templates WHERE is_builtin = 1')
    const total = TemplateDao.readNumber(countSet, 'total_count')
    countSet.close()
    if (total > 0) {
      return
    }
    const templates = await TemplateDao.readRawTemplates(context)
    for (const template of templates) {
      await TemplateDao.saveTemplate(context, template)
    }
  }

  static async listBuiltinTemplates(context: common.Context): Promise<Template[]> {
    const store = await DatabaseHelper.getInstance().getStore(context)
    const resultSet = await store.querySql('SELECT * FROM templates WHERE is_builtin = 1 ORDER BY name ASC')
    const list = TemplateDao.readList(resultSet)
    resultSet.close()
    return list
  }

  static async listCustomTemplates(context: common.Context): Promise<Template[]> {
    const store = await DatabaseHelper.getInstance().getStore(context)
    const resultSet = await store.querySql('SELECT * FROM templates WHERE is_builtin = 0 ORDER BY updated_at DESC')
    const list = TemplateDao.readList(resultSet)
    resultSet.close()
    return list
  }

  static async findById(context: common.Context, templateId: string): Promise<Template | null> {
    const store = await DatabaseHelper.getInstance().getStore(context)
    const resultSet = await store.querySql(`SELECT * FROM templates WHERE id = '${templateId}' LIMIT 1`)
    const template = TemplateDao.readSingle(resultSet)
    resultSet.close()
    return template
  }

  static async saveTemplate(context: common.Context, template: Template): Promise<void> {
    const store = await DatabaseHelper.getInstance().getStore(context)
    template.updatedAt = Date.now()
    if (template.createdAt <= 0) {
      template.createdAt = Date.now()
    }
    const existsSet = await store.querySql(`SELECT COUNT(id) AS total_count FROM templates WHERE id = '${template.id}'`)
    const exists = TemplateDao.readNumber(existsSet, 'total_count') > 0
    existsSet.close()
    const values = createTemplateRow(template) as relationalStore.ValuesBucket
    if (exists) {
      const predicates = new relationalStore.RdbPredicates(TemplateDao.tableName)
      predicates.equalTo('id', template.id)
      await store.update(values, predicates)
      return
    }
    await store.insert(TemplateDao.tableName, values)
  }

  static async saveCustomTemplate(context: common.Context, name: string, tripType: string, items: TemplateItem[]): Promise<string> {
    const templateId = `custom_${Date.now()}`
    const template = new Template({
      id: templateId,
      name: name,
      tripType: tripType,
      isBuiltin: false,
      items: items,
      createdAt: Date.now(),
      updatedAt: Date.now()
    })
    await TemplateDao.saveTemplate(context, template)
    return templateId
  }

  static async deleteTemplate(context: common.Context, templateId: string): Promise<void> {
    const store = await DatabaseHelper.getInstance().getStore(context)
    const predicates = new relationalStore.RdbPredicates(TemplateDao.tableName)
    predicates.equalTo('id', templateId)
    await store.delete(predicates)
  }

  static async applyTemplateToTrip(context: common.Context, templateId: string, tripId: number): Promise<void> {
    const template = await TemplateDao.findById(context, templateId)
    if (!template) {
      return
    }
    const existingItems = await ItemDao.listByTripId(context, tripId)
    let startOrder = existingItems.length
    for (const templateItem of template.items) {
      const item = new Item({
        tripId: tripId,
        templateId: template.id,
        name: templateItem.name,
        category: templateItem.category,
        quantity: templateItem.quantity,
        note: templateItem.note,
        isPacked: false,
        isMissed: false,
        sortOrder: startOrder,
        createdAt: Date.now(),
        updatedAt: Date.now()
      })
      startOrder += 1
      await ItemDao.save(context, item)
    }
  }

  private static async readRawTemplates(context: common.Context): Promise<Template[]> {
    const rawBuffer = await context.resourceManager.getRawFileContent('templates.json')
    const jsonText = TemplateDao.uint8ArrayToString(rawBuffer)
    const parsed = JSON.parse(jsonText) as Array<Record<string, string | boolean | number | Array<Record<string, string | number>>>>
    return parsed.map((source: Record<string, string | boolean | number | Array<Record<string, string | number>>>) => {
      const items = (source.items as Array<Record<string, string | number>>).map((item: Record<string, string | number>) => new TemplateItem({
        name: String(item.name),
        category: String(item.category),
        quantity: Number(item.quantity),
        note: String(item.note || '')
      }))
      return new Template({
        id: String(source.id),
        name: String(source.name),
        tripType: String(source.tripType),
        isBuiltin: Boolean(source.isBuiltin),
        items: items,
        createdAt: Date.now(),
        updatedAt: Date.now()
      })
    })
  }

  private static uint8ArrayToString(rawBuffer: Uint8Array): string {
    let text = ''
    for (let index = 0; index < rawBuffer.length; index += 1) {
      text += String.fromCharCode(rawBuffer[index])
    }
    return text
  }

  private static readList(resultSet: relationalStore.ResultSet): Template[] {
    const list: Template[] = []
    if (resultSet.rowCount === 0) {
      return list
    }
    resultSet.goToFirstRow()
    do {
      list.push(TemplateDao.readTemplate(resultSet))
    } while (resultSet.goToNextRow())
    return list
  }

  private static readSingle(resultSet: relationalStore.ResultSet): Template | null {
    if (resultSet.rowCount === 0) {
      return null
    }
    resultSet.goToFirstRow()
    return TemplateDao.readTemplate(resultSet)
  }

  private static readTemplate(resultSet: relationalStore.ResultSet): Template {
    const payload = TemplateDao.getString(resultSet, 'item_payload')
    const items = payload.length > 0 ? (JSON.parse(payload) as Array<Record<string, string | number>>).map((item: Record<string, string | number>) => new TemplateItem({
      name: String(item.name),
      category: String(item.category),
      quantity: Number(item.quantity),
      note: String(item.note || '')
    })) : []
    return new Template({
      id: TemplateDao.getString(resultSet, 'id'),
      name: TemplateDao.getString(resultSet, 'name'),
      tripType: TemplateDao.getString(resultSet, 'trip_type'),
      isBuiltin: TemplateDao.getNumber(resultSet, 'is_builtin') === 1,
      items: items,
      createdAt: TemplateDao.getNumber(resultSet, 'created_at'),
      updatedAt: TemplateDao.getNumber(resultSet, 'updated_at')
    })
  }

  private static readNumber(resultSet: relationalStore.ResultSet, columnName: string): number {
    if (resultSet.rowCount === 0) {
      return 0
    }
    resultSet.goToFirstRow()
    return TemplateDao.getNumber(resultSet, columnName)
  }

  private static getNumber(resultSet: relationalStore.ResultSet, columnName: string): number {
    const index = resultSet.getColumnIndex(columnName)
    return index >= 0 ? Number(resultSet.getLong(index)) : 0
  }

  private static getString(resultSet: relationalStore.ResultSet, columnName: string): string {
    const index = resultSet.getColumnIndex(columnName)
    return index >= 0 ? resultSet.getString(index) : ''
  }
}
