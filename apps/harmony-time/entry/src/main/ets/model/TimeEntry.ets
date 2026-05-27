export interface TimeEntry {
  id: number;
  projectId: number;
  startTime: number;
  endTime: number;
  duration: number;
  note: string;
  createdAt: number;
}

export function createTimeEntry(projectId: number, startTime: number, endTime: number, note: string): TimeEntry {
  const now: number = Date.now();
  const normalizedEndTime: number = endTime > 0 ? endTime : 0;
  return {
    id: now,
    projectId,
    startTime,
    endTime: normalizedEndTime,
    duration: normalizedEndTime > 0 ? Math.max(0, Math.floor((normalizedEndTime - startTime) / 1000)) : 0,
    note,
    createdAt: now
  };
}
