/**
 * RDB 封装：答题记录表 answer_record + 错题本表 wrong_book
 */
import relationalStore from '@ohos.data.relationalStore'
import common from '@ohos.app.ability.common'

export interface AnswerRecord {
  qid: number
  subject: number
  correct: number
  answeredAt: string
}

export interface WrongEntry {
  qid: number
  subject: number
  wrongCount: number
  lastWrongAt: string
}

export class DbHelper {
  private static rdb: relationalStore.RdbStore | null = null
  private static initing: Promise<void> | null = null

  static async init(context: common.UIAbilityContext): Promise<void> {
    if (DbHelper.rdb) {
      return
    }
    if (DbHelper.initing) {
      return DbHelper.initing
    }
    DbHelper.initing = new Promise<void>(async (resolve, reject) => {
      try {
        const store = await relationalStore.getRdbStore(context, {
          name: 'drive.db',
          securityLevel: relationalStore.SecurityLevel.S1
        })
        await store.executeSql(
          `CREATE TABLE IF NOT EXISTS answer_record (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            qid INTEGER NOT NULL,
            subject INTEGER NOT NULL,
            correct INTEGER NOT NULL,
            answered_at TEXT NOT NULL
          )`)
        await store.executeSql(
          `CREATE TABLE IF NOT EXISTS wrong_book (
            qid INTEGER PRIMARY KEY,
            subject INTEGER NOT NULL,
            wrong_count INTEGER NOT NULL DEFAULT 1,
            last_wrong_at TEXT NOT NULL
          )`)
        DbHelper.rdb = store
        resolve()
      } catch (err) {
        reject(err)
      }
    })
    return DbHelper.initing
  }

  static now(): string {
    const d = new Date()
    const p = (n: number) => n.toString().padStart(2, '0')
    return `${d.getFullYear()}-${p(d.getMonth() + 1)}-${p(d.getDate())} ${p(d.getHours())}:${p(d.getMinutes())}:${p(d.getSeconds())}`
  }

  /** 记录一次答题，错题则写入/更新错题本 */
  static async insertAnswer(qid: number, subject: number, correct: number): Promise<void> {
    const db = await DbHelper.ensure()
    const row: relationalStore.ValuesBucket = {
      'qid': qid,
      'subject': subject,
      'correct': correct,
      'answered_at': DbHelper.now()
    }
    await db.insert('answer_record', row)
    if (correct === 0) {
      await DbHelper.addWrong(qid, subject)
    } else {
      await DbHelper.removeWrong(qid)
    }
  }

  static async addWrong(qid: number, subject: number): Promise<void> {
    const db = await DbHelper.ensure()
    const exist = await db.querySql(`SELECT qid, wrong_count FROM wrong_book WHERE qid = ?`, [qid])
    if (exist.rowCount > 0) {
      await db.executeSql(
        `UPDATE wrong_book SET wrong_count = wrong_count + 1, last_wrong_at = ? WHERE qid = ?`,
        [DbHelper.now(), qid])
    } else {
      const row: relationalStore.ValuesBucket = {
        'qid': qid,
        'subject': subject,
        'wrong_count': 1,
        'last_wrong_at': DbHelper.now()
      }
      await db.insert('wrong_book', row)
    }
  }

  static async removeWrong(qid: number): Promise<void> {
    const db = await DbHelper.ensure()
    await db.executeSql(`DELETE FROM wrong_book WHERE qid = ?`, [qid])
  }

  static async removeWrongBatch(qids: number[]): Promise<void> {
    const db = await DbHelper.ensure()
    for (const qid of qids) {
      await db.executeSql(`DELETE FROM wrong_book WHERE qid = ?`, [qid])
    }
  }

  static async wrongList(subject: number): Promise<WrongEntry[]> {
    const db = await DbHelper.ensure()
    const rs = await db.querySql(
      `SELECT qid, subject, wrong_count, last_wrong_at FROM wrong_book WHERE subject = ? ORDER BY last_wrong_at DESC`,
      [subject])
    const list: WrongEntry[] = []
    while (rs.goToNextRow()) {
      list.push({
        qid: rs.getLong(rs.getColumnIndex('qid')),
        subject: rs.getLong(rs.getColumnIndex('subject')),
        wrongCount: rs.getLong(rs.getColumnIndex('wrong_count')),
        lastWrongAt: rs.getString(rs.getColumnIndex('last_wrong_at'))
      })
    }
    rs.close()
    return list
  }

  static async wrongCount(subject: number): Promise<number> {
    const db = await DbHelper.ensure()
    const rs = await db.querySql(`SELECT COUNT(*) AS c FROM wrong_book WHERE subject = ?`, [subject])
    let cnt = 0
    if (rs.goToNextRow()) {
      cnt = rs.getLong(rs.getColumnIndex('c'))
    }
    rs.close()
    return cnt
  }

  static async allAnswers(): Promise<AnswerRecord[]> {
    const db = await DbHelper.ensure()
    const rs = await db.querySql(`SELECT qid, subject, correct, answered_at FROM answer_record ORDER BY id`)
    const list: AnswerRecord[] = []
    while (rs.goToNextRow()) {
      list.push({
        qid: rs.getLong(rs.getColumnIndex('qid')),
        subject: rs.getLong(rs.getColumnIndex('subject')),
        correct: rs.getLong(rs.getColumnIndex('correct')),
        answeredAt: rs.getString(rs.getColumnIndex('answered_at'))
      })
    }
    rs.close()
    return list
  }

  static async answeredQids(): Promise<Set<number>> {
    const list = await DbHelper.allAnswers()
    return new Set(list.map(r => r.qid))
  }

  /** 今日答题数 */
  static async todayCount(): Promise<number> {
    const db = await DbHelper.ensure()
    const key = DbHelper.now().slice(0, 10)
    const rs = await db.querySql(`SELECT COUNT(*) AS c FROM answer_record WHERE answered_at LIKE ?`, [key + '%'])
    let cnt = 0
    if (rs.goToNextRow()) {
      cnt = rs.getLong(rs.getColumnIndex('c'))
    }
    rs.close()
    return cnt
  }

  private static async ensure(): Promise<relationalStore.RdbStore> {
    if (DbHelper.rdb) {
      return DbHelper.rdb
    }
    throw new Error('DbHelper 未初始化，请先调用 DbHelper.init(context)')
  }
}
