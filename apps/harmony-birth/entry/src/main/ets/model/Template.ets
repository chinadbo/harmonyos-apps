export interface Template {
  id: number;
  content: string;
  category: string;
}

export class TemplateRecord implements Template {
  id: number = 0;
  content: string = '';
  category: string = 'general';

  constructor(data?: Partial<Template>) {
    if (data) {
      this.id = data.id ?? 0;
      this.content = data.content ?? '';
      this.category = data.category ?? 'general';
    }
  }
}
