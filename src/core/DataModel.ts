// Improved DataModel with simple eventing and transactional API
export type TxResult = {
  added: any[]
  updated: any[]
  removed: any[]
}

type Listener = (payload?: any) => void

export class DataModel {
  private rows: any[] = []
  private listeners: Map<string, Listener[]> = new Map()

  constructor(initial: any[] = []) {
    this.rows = initial.slice()
  }

  // Event API: on/off/emit
  on(event: string, fn: Listener) {
    const l = this.listeners.get(event) || []
    l.push(fn)
    this.listeners.set(event, l)
  }

  off(event: string, fn?: Listener) {
    if (!fn) { this.listeners.delete(event); return }
    const l = this.listeners.get(event) || []
    this.listeners.set(event, l.filter(x => x !== fn))
  }

  private emit(event: string, payload?: any) {
    const l = this.listeners.get(event) || []
    l.forEach(fn => { try { fn(payload) } catch(e) { /* swallow */ } })
  }

  getAll() { return this.rows.slice() }

  getRowIndex(predicate: (r: any) => boolean) {
    return this.rows.findIndex(predicate)
  }

  getById(id: any) { return this.rows.find(r => r.id === id) }

  // Apply a simple transaction: add/update/remove
  applyTransaction(tx: { add?: any[], update?: any[], remove?: any[] } = {}): TxResult {
    const result: TxResult = { added: [], updated: [], removed: [] }

    if (tx.add && tx.add.length) {
      tx.add.forEach(r => {
        this.rows.push(r)
        result.added.push(r)
      })
    }

    if (tx.update && tx.update.length) {
      tx.update.forEach(u => {
        const idx = this.rows.findIndex(r => r.id === u.id)
        if (idx >= 0) {
          const before = this.rows[idx]
          this.rows[idx] = { ...this.rows[idx], ...u }
          result.updated.push({ before, after: this.rows[idx] })
        }
      })
    }

    if (tx.remove && tx.remove.length) {
      tx.remove.forEach(rm => {
        const idx = this.rows.findIndex(r => r.id === rm.id)
        if (idx >= 0) {
          const removed = this.rows.splice(idx, 1)[0]
          result.removed.push(removed)
        }
      })
    }

    // Emit change event with the diff
    this.emit('change', result)
    return result
  }
}
