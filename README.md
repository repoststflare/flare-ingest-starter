# Integración Flare: Plan y Guía de Configuración

## Introducción

Este documento reúde todos los componentes para implementar un sistema de ingestión y distribución de fotografías deportivas para la marca Flare. La solución se basa en un MVP de ingesta (Ingesta v0) compatible con cualquier cámara (profesional, celular, etc.) y utiliza un pipeline de IA para mejorar las fotos, identificarlas y distribuirlas a las jugadoras. También se describen extensiones para identificación avanzada, monetización y una visión de futuro.

## Arquitectura del MVP (Ingesta v0)

- **Captura universal**: fotógrafos pueden utilizar su Canon EOS T7, cualquier DSLR/Mirrorless con Wi‑Fi/FTP, o un celular. Las fotos se copian al celular o laptop y se suben desde ahí.
- **Uploader Flare (PWA)**: una aplicación web que permite subir fotos de forma sencilla desde el navegador del celular o la laptop. Cada evento tiene un `event_id` y un QR que se escanea para saber dónde enviar la foto.
- **Almacenamiento y base de datos**:
  - **Supabase**: gestiona la base de datos Postgres, la autenticación y la suscripción en tiempo real (`photos`).
  - **Buckets S3/R2**: guardan las imágenes (`raw` y `processed`) mediante URLs firmadas (presigned URL).
- **Worker de edición (Worker‑Edit)**: proceso automático que ajusta exposición, color, nitidez y aplica la marca de agua “FLARE”, generando la imagen final.
- **Galería en vivo**: una página que escucha los cambios de `photos` y muestra las imágenes conforme se suben y procesan.
- **Flujo de subida**:
  1. El fotógrafo abre el Uploader, escanea el QR de evento y selecciona/ toma la foto.
  2. Pide una URL firmada al backend y sube la foto `raw`.
  3. Envía metadatos (`event_id`, hora, tags) a la API.
  4. La foto aparece en la galería en segundos; cuando el Worker‑Edit termina, la imagen final reemplaza a la preliminar.

## Diseño extendido para identificar jugadoras (Worker‑ID)

- **Objetivo**: asignar automáticamente cada foto a la jugadora correcta usando señales como:
  - **OCR del dorsal**: detecta el número en la camiseta.
  - **Color del uniforme**: determina el equipo (A/B).
  - **QR o pulsera**: se entrega una pulsera QR a cada jugadora; si aparece en la foto, la identificación es casi perfecta.
  - **Reconocimiento facial (opt-in)**: opcional y sólo con consentimiento.
  - **Contexto tiempo/cancha**: filtra por roster y horario del partido.
- **Cálculo de score**: cada señal aporta un porcentaje de confianza. Si el score es alto (≥0.85), se asigna automáticamente; si es medio (0.5–0.85), se envía a moderación; si es bajo, sólo se etiqueta el equipo.
- **Tablas recomendadas**:
  - `rosters`: relaciona `event_id`, `team_id`, `athlete_id` y número de jersey.
  - `athletes`: datos de jugadoras, QR y face embeddings (si aplica).
  - Ampliación de `photos` con columnas `athlete_id`, `team_id`, `id_confidence` y `id_sources` para guardar señales.
  - `claims`: permite que la jugadora reclame una foto no asignada.
- **Moderación**: una interfaz que muestra fotos con baja confianza y propone la jugadora; el moderador confirma en dos clics.

## Recomendaciones y extras

- **Experiencia de usuario**:
  - Álbum privado y familiar, notificaciones push cuando hay nuevas fotos.
  - Highlights automáticos y vídeos con las mejores jugadas.
  - Estadísticas, badges y logros.
- **Monetización**:
  - Paquetes premium (descarga HD, sin marca de agua, impresión).
  - Suscripciones para clubes; publicidad local en torneos.
  - Print‑on‑demand (pósters, camisetas), revistas personalizadas.
  - Marketplace de servicios: contratar fotógrafos, diseñadores, narradores.
- **Tecnología y escalabilidad**:
  - Uploader offline (subida en cola si no hay internet).
  - Clasificación híbrida IA + humanos para máxima precisión.
  - Ajuste de pesos de identificación según resultados reales.
- **Seguridad y privacidad**:
  - Consentimientos claros para menores y control parental.
  - Álbumes privados; desenfoque o no mostrar fotos sin permiso.
  - Opción de reclamar/eliminar una foto.

## Pasos para configurar el proyecto

1. **Crear un repositorio GitHub**: por ejemplo, `flare-ingest-starter`.  
2. **Descargar el starter kit** (archivo ZIP) y descomprimirlo en tu máquina.  
3. **Copiar los archivos al repositorio** y ejecutar:
   ```bash
   git init
   git add .
   git commit -m "Initial Flare Ingest v0"
   git remote add origin https://github.com/<tuusuario>/<turepo>.git
   git push -u origin main
   ```
4. **Configurar Supabase**:
   - Crear un proyecto en [supabase.com](https://supabase.com).
   - Ejecutar el script `supabase_schema.sql` para crear las tablas `events` y `photos`, y activar Realtime en `photos`.
5. **Configurar almacenamiento**:
   - Crear un bucket `flare-events` en Cloudflare R2 o AWS S3.
   - Obtener claves de acceso (Access Key, Secret) y configurar `S3_ACCESS_KEY`, `S3_SECRET_KEY`, etc.
6. **Variables de entorno**: duplicar `.env.local.example` a `.env.local` y completar:
   ```
   NEXT_PUBLIC_SUPABASE_URL=<url_supabase>
   NEXT_PUBLIC_SUPABASE_ANON_KEY=<anon_key>
   SUPABASE_SERVICE_ROLE_KEY=<service_role_key>
   S3_ACCESS_KEY=<key>
   S3_SECRET_KEY=<secret>
   S3_BUCKET=<nombre_bucket>
   S3_PUBLIC_BASE=<https://tu-endpoint-r2-aws>
   ```
7. **Instalar dependencias y ejecutar localmente**:
   ```bash
   npm install
   npm run dev
   ```
   Navegar a:
   - Uploader: `http://localhost:3000/uploader?event=<tu_event_id>`
   - Galería: `http://localhost:3000/gallery/<tu_event_id>`
8. **Crear un `event_id`** en la tabla `events` con el nombre del torneo, fecha, etc.  
9. **Probar el sistema**: subir una foto desde cualquier cámara (importada al celular/laptop) y verificar que aparece en la galería.
10. **Implementar el Worker de edición** (script Node que procesa imágenes y actualiza la base).  
11. **Extender con Worker‑ID** y moderación cuando quieras automatizar la asignación de jugadoras.  
12. **Deployment**: desplegar en Vercel o similar. Recuerda configurar las mismas variables de entorno.

## Cómo contribuir

Para integrar esta guía en GitHub:

1. Crea este archivo `README.md` (u otro nombre) con el contenido completo.  
2. Súbelo al repositorio junto con el código.  
3. Utiliza issues y proyectos en GitHub para dividir las tareas (MVP, Worker‑ID, extras).  

Con esto tendrás en un solo lugar toda la documentación para arrancar, operar y evolucionar el sistema fotográfico de Flare.
  
