import { describe, it, expect } from 'vitest'
import { DataModel } from '../core/DataModel'

describe('DataModel', () => {
  it('applies add/update/remove transactions', () => {
    const dm = new DataModel([{ id: 1, v: 10 }, { id: 2, v: 20 }])
    const res1 = dm.applyTransaction({ add: [{ id: 3, v: 30 }] })
    expect(res1.added.length).toBe(1)
    expect(dm.getAll().length).toBe(3)

    const res2 = dm.applyTransaction({ update: [{ id: 2, v: 22 }] })
    expect(res2.updated.length).toBe(1)
    expect(dm.getById(2).v).toBe(22)

    const res3 = dm.applyTransaction({ remove: [{ id: 1 }] })
    expect(res3.removed.length).toBe(1)
    expect(dm.getAll().find(r => r.id === 1)).toBeUndefined()
  })
})
