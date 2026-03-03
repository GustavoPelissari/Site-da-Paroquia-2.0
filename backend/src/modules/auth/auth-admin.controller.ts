import { Body, Controller, Get, Put, UseGuards } from '@nestjs/common';
import { AccessLevel } from '../../common/access-level';
import { MinAccessLevel } from '../../common/roles.decorator';
import { RolesGuard } from '../../common/roles.guard';
import { JwtAuthGuard } from './jwt-auth.guard';
import { UpdateSmtpSettingsDto } from './dto/update-smtp-settings.dto';
import { SmtpSettingsService } from './smtp-settings.service';

@Controller('auth/admin')
@UseGuards(JwtAuthGuard, RolesGuard)
@MinAccessLevel(AccessLevel.ADMINISTRATIVO)
export class AuthAdminController {
  constructor(private readonly smtpSettings: SmtpSettingsService) {}

  @Get('mail-settings')
  async getMailSettings() {
    const config = await this.smtpSettings.getForAdmin();
    if (!config) {
      return {
        configured: false,
      };
    }
    return {
      configured: true,
      ...config,
    };
  }

  @Put('mail-settings')
  async updateMailSettings(@Body() dto: UpdateSmtpSettingsDto) {
    const config = await this.smtpSettings.upsert(dto);
    return {
      configured: true,
      ...config,
    };
  }
}

