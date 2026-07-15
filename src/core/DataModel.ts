// Minimal DataModel skeleton (clean-room implementation placeholder)
export class DataModel {
  private rows: any[] = []

  constructor(initial: any[] = []) {
    this.rows = initial.slice()
  }

  getAll() { return this.rows }

  getById(id: any) { return this.rows.find(r => r.id === id) }

  applyTransaction(tx: { add?: any[], update?: any[], remove?: any[] }) {
    // TODO: implement transactional updates with diffs and events
    if (tx.add) this.rows.push(...tx.add)
    if (tx.update) tx.update.forEach(u => {
      const idx = this.rows.findIndex(r => r.id === u.id)
      if (idx >= 0) this.rows[idx] = { ...this.rows[idx], ...u }
    })
    if (tx.remove) tx.remove.forEach(rm => {
      const idx = this.rows.findIndex(r => r.id === rm.id)
      if (idx >= 0) this.rows.splice(idx, 1)
    })
  }
}
