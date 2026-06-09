export interface Medicine {
  id: number
  name: string
  spec: string
  notes: string
  stock: number
  unit: string
}

export function createEmptyMedicine(): Medicine {
  return {
    id: 0,
    name: '',
    spec: '',
    notes: '',
    stock: 0,
    unit: '片'
  }
}
