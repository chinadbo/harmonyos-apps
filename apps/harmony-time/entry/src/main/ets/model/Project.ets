export interface Project {
  id: number;
  name: string;
  color: string;
  icon: string;
  totalTime: number;
  createdAt: number;
}

export function createProject(name: string, color: string, icon: string): Project {
  const now: number = Date.now();
  return {
    id: now,
    name,
    color,
    icon,
    totalTime: 0,
    createdAt: now
  };
}
