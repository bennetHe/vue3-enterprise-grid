// ColumnModel with state management utilities
export interface ColumnState {
  key: string
  visible?: boolean
  width?: number
  order?: number
}

export class ColumnModel {
  private cols: ColumnState[] = []

  constructor(cols: ColumnState[] = []) {
    // Normalize
    this.cols = cols.map((c, i) => ({ order: i, visible: c.visible !== false, width: c.width, key: c.key }))
  }

  getAll() { return this.cols.slice().sort((a,b) => (a.order ?? 0) - (b.order ?? 0)) }

  getColumn(key: string) { return this.cols.find(c => c.key === key) }

  setVisibility(key: string, visible: boolean) {
    const c = this.getColumn(key)
    if (c) c.visible = visible
  }

  setWidth(key: string, width: number) {
    const c = this.getColumn(key)
    if (c) c.width = width
  }

  moveColumn(key: string, newIndex: number) {
    const cols = this.getAll()
    const idx = cols.findIndex(c => c.key === key)
    if (idx === -1) return
    const [item] = cols.splice(idx,1)
    cols.splice(newIndex, 0, item)
    // reassign order
    cols.forEach((c,i) => c.order = i)
    this.cols = cols
  }

  getState(): ColumnState[] { return this.getAll() }

  applyState(state: ColumnState[]) {
    // Replace state by matching key and merging
    state.forEach(s => {
      const c = this.getColumn(s.key)
      if (c) Object.assign(c, s)
      else this.cols.push(s)
    })
    // normalize order
    this.cols.forEach((c,i) => { if (c.order === undefined) c.order = i })
  }
}
