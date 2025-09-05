# Flare Ingest v0 — Starter

Sube fotos desde cualquier cámara (vía celular o laptop) a la nube de Flare, procésalas con IA básica y míralas al instante en la galería por evento.

## Setup rápido
1) Crea proyecto en **Supabase** y copia URL + keys (anon y service-role).
2) Crea bucket en **Cloudflare R2** o **S3** (`flare-events`) y credenciales.
3) Copia `.env.local.example` a `.env.local` y complétalo.
4) Instala deps y corre:
```bash
npm install
npm run dev
```
5) Crea un `event_id` (UUID) en la tabla `events` (puedes hacerlo luego).
6) En el dashboard de Supabase, activa **Realtime** para la tabla `photos` (Replication).

## Rutas clave
- `/uploader?event=<uuid>` — subir desde cámara/galería.
- `/gallery/<uuid>` — ver la galería en vivo.

## Producción
- Deploy en Vercel (agrega tus ENV).
- Conecta el `scripts/worker-ia.mjs` a una cola o función programada.
