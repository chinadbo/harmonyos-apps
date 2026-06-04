import promptAction from '@ohos.promptAction';
import { ReminderItem, createEmptyReminder } from '../models/Reminder';
import { Vehicle } from '../models/Vehicle';
import { carService } from '../services/CarService';
import { reminderService } from '../services/ReminderService';
import { parseInteger } from '../utils/Formatters';
import { ReminderCard } from '../views/ReminderCard';
import { ReminderFormView } from '../views/ReminderFormView';
import { SectionHeader } from '../views/SectionHeader';

@Component
export struct RemindersPage {
  @Prop stack: NavPathStack = new NavPathStack();
  @State reminders: ReminderItem[] = [];
  @State vehicles: Vehicle[] = [];
  @State selectedVehicleId: number = 0;
  @State type: string = '保养';
  @State title: string = '';
  @State content: string = '';
  @State triggerDate: string = '';
  @State targetMileageText: string = '0';
  @State isActive: boolean = true;

  aboutToAppear(): void {
    this.refresh();
  }

  private async refresh(): Promise<void> {
    this.vehicles = await carService.list();
    if (this.selectedVehicleId === 0 && this.vehicles.length > 0) {
      this.selectedVehicleId = this.vehicles[0].id;
    }
    this.reminders = await reminderService.list();
    if (this.triggerDate.length === 0) {
      const reminder: ReminderItem = createEmptyReminder(this.selectedVehicleId);
      this.triggerDate = reminder.triggerDate;
      this.title = reminder.title;
      this.content = reminder.content;
    }
  }

  private async saveReminder(): Promise<void> {
    const payload: ReminderItem = {
      id: 0,
      vehicleId: this.selectedVehicleId,
      reminderId: 0,
      type: this.type,
      title: this.title.length > 0 ? this.title : '车辆提醒',
      content: this.content.length > 0 ? this.content : '请及时处理车辆事项。',
      triggerDate: this.triggerDate,
      targetMileage: parseInteger(this.targetMileageText),
      isActive: this.isActive,
      createdAt: ''
    };
    await reminderService.save(payload);
    promptAction.showToast({ message: '提醒已保存' });
    this.title = '';
    this.content = '';
    this.targetMileageText = '0';
    await this.refresh();
  }

  build() {
    Scroll() {
      Column({ space: 16 }) {
        SectionHeader({ title: '新建提醒' })
        if (this.vehicles.length > 0) {
          Text('选择车辆')
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .width('100%')
            .textAlign(TextAlign.Start)
          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(this.vehicles, (vehicle: Vehicle) => {
              Text(vehicle.plateNumber)
                .fontSize(13)
                .fontColor(this.selectedVehicleId === vehicle.id ? '#FFFFFF' : '#4E7BF2')
                .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                .backgroundColor(this.selectedVehicleId === vehicle.id ? '#4E7BF2' : '#EAF0FF')
                .borderRadius(14)
                .margin({ right: 8, bottom: 8 })
                .onClick(() => {
                  this.selectedVehicleId = vehicle.id;
                })
            }, (vehicle: Vehicle) => `${vehicle.id}`)
          }
          .width('100%')
        }
        ReminderFormView({
          type: $type,
          title: $title,
          content: $content,
          triggerDate: $triggerDate,
          targetMileageText: $targetMileageText,
          isActive: $isActive
        })
        Button('保存提醒')
          .width('100%')
          .height(44)
          .backgroundColor('#4E7BF2')
          .onClick(() => {
            this.saveReminder();
          })

        SectionHeader({ title: '提醒列表' })
        ForEach(this.reminders, (item: ReminderItem) => {
          ReminderCard({ reminder: item, onToggle: async (reminderId: number, enabled: boolean) => {
            const reminder: ReminderItem | undefined = this.reminders.find((current: ReminderItem) => current.id === reminderId);
            if (!reminder) {
              return;
            }
            await reminderService.toggle(reminder, enabled);
            this.refresh();
          }})
        }, (item: ReminderItem) => `${item.id}`)
      }
      .padding(16)
      .width('100%')
    }
    .backgroundColor('#F3F6FB')
  }
}
