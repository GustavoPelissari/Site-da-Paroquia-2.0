import {
  BadRequestException,
  Controller,
  Get,
  Post,
  Query,
  UploadedFile,
  UseGuards,
  UseInterceptors,
} from '@nestjs/common';
import { AccessLevel } from '../../common/access-level';
import { MinAccessLevel } from '../../common/roles.decorator';
import { RolesGuard } from '../../common/roles.guard';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { extname } from 'path';
import { FileInterceptor } from '@nestjs/platform-express';
import { diskStorage } from 'multer';
import { readdirSync, statSync } from 'fs';
import { join } from 'path';

const allowedExt = new Set(['.png', '.jpg', '.jpeg']);
const allowedFolders = new Set(['noticias', 'eventos', 'grupos', 'geral']);

function sanitizeFolder(raw?: string) {
  const folder = (raw ?? 'geral').trim().toLowerCase();
  if (!allowedFolders.has(folder)) {
    throw new BadRequestException('Pasta invalida. Use: noticias, eventos, grupos ou geral.');
  }
  return folder;
}

@Controller('uploads')
@UseGuards(JwtAuthGuard, RolesGuard)
@MinAccessLevel(AccessLevel.COORDENADOR)
export class UploadsController {
  @Post('image')
  @UseInterceptors(
    FileInterceptor('file', {
      storage: diskStorage({
        destination: './uploads',
        filename: (_req: any, file: any, cb: any) => {
          const extension = extname(file.originalname).toLowerCase();
          const unique = `${Date.now()}-${Math.round(Math.random() * 1e9)}`;
          cb(null, `${unique}${extension}`);
        },
      }),
      limits: { fileSize: 5 * 1024 * 1024 },
      fileFilter: (_req, file, cb) => {
        const extension = extname(file.originalname).toLowerCase();
        if (!allowedExt.has(extension)) {
          cb(new BadRequestException('Apenas PNG/JPG/JPEG sao permitidos.'), false);
          return;
        }
        cb(null, true);
      },
    }),
  )
  uploadImage(@UploadedFile() file: any, @Query('folder') folderRaw?: string) {
    if (!file) {
      throw new BadRequestException('Arquivo nao enviado.');
    }
    const folder = sanitizeFolder(folderRaw);
    const oldPath = file.path as string;
    const finalDir = join(process.cwd(), 'uploads', folder);
    const finalPath = join(finalDir, file.filename);
    const fs = require('fs');
    if (!fs.existsSync(finalDir)) fs.mkdirSync(finalDir, { recursive: true });
    fs.renameSync(oldPath, finalPath);
    return {
      url: `/uploads/${folder}/${file.filename}`,
      filename: file.filename,
      folder,
      mimeType: file.mimetype,
      size: file.size,
    };
  }

  @Get('gallery')
  listGallery(@Query('folder') folderRaw?: string) {
    const folder = sanitizeFolder(folderRaw);
    const dir = join(process.cwd(), 'uploads', folder);
    let files: string[] = [];
    try {
      files = readdirSync(dir);
    } catch {
      return { folder, items: [] };
    }
    const items = files
      .filter((name) => allowedExt.has(extname(name).toLowerCase()))
      .map((name) => {
        const absolute = join(dir, name);
        const stat = statSync(absolute);
        return {
          filename: name,
          folder,
          url: `/uploads/${folder}/${name}`,
          size: stat.size,
          updatedAt: stat.mtime.toISOString(),
        };
      })
      .sort((a, b) => (a.updatedAt > b.updatedAt ? -1 : 1));
    return { folder, items };
  }
}
