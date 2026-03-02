import { Injectable } from '@nestjs/common';

type MassSlot = {
  dayOfWeek: number;
  dayLabel: string;
  time: string;
  location: string;
};

@Injectable()
export class ParishService {
  private readonly mapUrl =
    'https://www.google.com/maps?q=Av.+Gen.+Mascarenhas+Moraes,+4969+-+Zona+V,+Umuarama+-+PR,+87504-090';

  private readonly massSchedule: MassSlot[] = [
    { dayOfWeek: 1, dayLabel: 'Segunda', time: '06:00', location: 'Paroquia' },
    { dayOfWeek: 2, dayLabel: 'Terca', time: '06:00', location: 'Paroquia' },
    { dayOfWeek: 4, dayLabel: 'Quinta', time: '06:00', location: 'Paroquia' },
    { dayOfWeek: 5, dayLabel: 'Sexta', time: '06:00', location: 'Paroquia' },
    { dayOfWeek: 3, dayLabel: 'Quarta', time: '06:30', location: 'Paroquia' },
    {
      dayOfWeek: 6,
      dayLabel: 'Sabado',
      time: '18:00',
      location: 'Capela Nossa Senhora de Fatima',
    },
    { dayOfWeek: 6, dayLabel: 'Sabado', time: '19:30', location: 'Paroquia' },
    { dayOfWeek: 0, dayLabel: 'Domingo', time: '08:00', location: 'Capela Santo Antonio' },
    { dayOfWeek: 0, dayLabel: 'Domingo', time: '09:30', location: 'Paroquia' },
    { dayOfWeek: 0, dayLabel: 'Domingo', time: '18:00', location: 'Paroquia' },
  ];

  getParishInfo() {
    return {
      address: 'Av. Gen. Mascarenhas Moraes, 4969 - Zona V, Umuarama - PR, 87504-090',
      mapUrl: this.mapUrl,
      imageAssetKey: 'web-next/public/img/IMAGEM DE SAO PAULO APOSTOLO MONOCROMATICA.png',
      officeHours: [{ label: 'Secretaria', value: 'Em atualizacao' }],
      massSchedule: [
        { day: 'Seg, Ter, Qui, Sex', times: ['06:00 (Paroquia)'] },
        { day: 'Quarta', times: ['06:30 (Paroquia)'] },
        {
          day: 'Sabado',
          times: ['18:00 (Capela Nossa Senhora de Fatima)', '19:30 (Paroquia)'],
        },
        {
          day: 'Domingo',
          times: [
            '08:00 (Capela Santo Antonio)',
            '09:30 (Paroquia)',
            '18:00 (Paroquia)',
          ],
        },
      ],
    };
  }

  getNextMass(now = new Date()) {
    const next = this.massSchedule
      .map((slot) => ({
        ...slot,
        startsAt: this.resolveNextDate(slot.dayOfWeek, slot.time, now),
      }))
      .sort((a, b) => a.startsAt.getTime() - b.startsAt.getTime())[0];

    return {
      day: next.dayLabel,
      time: next.time,
      location: next.location,
      startsAt: next.startsAt.toISOString(),
      serverNow: now.toISOString(),
    };
  }

  private resolveNextDate(targetDay: number, hhmm: string, now: Date) {
    const [hh, mm] = hhmm.split(':').map(Number);
    const candidate = new Date(now);
    const diff = (targetDay - now.getDay() + 7) % 7;
    candidate.setDate(now.getDate() + diff);
    candidate.setHours(hh, mm, 0, 0);

    if (candidate.getTime() <= now.getTime()) {
      candidate.setDate(candidate.getDate() + 7);
    }

    return candidate;
  }
}
