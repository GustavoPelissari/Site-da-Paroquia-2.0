import { SetMetadata } from '@nestjs/common';
import { AccessLevel } from './access-level';

export const MIN_ACCESS_LEVEL_KEY = 'minAccessLevel';
export const MinAccessLevel = (level: AccessLevel) =>
  SetMetadata(MIN_ACCESS_LEVEL_KEY, level);