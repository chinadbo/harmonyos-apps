export class TemplateItem {
  name: string = ''
  category: string = 'other'
  quantity: number = 1
  note: string = ''

  constructor(source?: Partial<TemplateItem>) {
    if (source) {
      Object.assign(this, source)
    }
  }
}

export class Template {
  id: string = ''
  name: string = ''
  tripType: string = 'leisure'
  isBuiltin: boolean = false
  items: TemplateItem[] = []
  createdAt: number = Date.now()
  updatedAt: number = Date.now()

  constructor(source?: Partial<Template>) {
    if (source) {
      Object.assign(this, source)
      this.items = (source?.items || []).map((item: TemplateItem | Partial<TemplateItem>) => new TemplateItem(item))
    }
  }
}

export function createTemplateRow(template: Template): Record<string, number | string> {
  return {
    id: template.id,
    name: template.name,
    trip_type: template.tripType,
    is_builtin: template.isBuiltin ? 1 : 0,
    item_count: template.items.length,
    item_payload: JSON.stringify(template.items),
    created_at: template.createdAt,
    updated_at: template.updatedAt
  }
}
