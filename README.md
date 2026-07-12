# GuayGo (GuayApp)

App social de misiones diarias con fotos, ligas y ranking. Cliente Godot 4.6 + backend Go.

## Enlaces

| Servicio | URL |
|----------|-----|
| Web (Firebase) | https://guay-app-social.web.app |
| API (Render) | https://guayapp.onrender.com |
| Repositorio | https://github.com/SegniniJose/GuayApp |
| iOS Xcode (descarga) | [Releases](https://github.com/SegniniJose/GuayApp/releases) o [Actions → macOS workflow](https://github.com/SegniniJose/GuayApp/actions/workflows/build-ios-macos.yml) |

## Para el cliente (Mac + iPhone)

Lee **[CLIENTE_iOS.md](CLIENTE_iOS.md)** — pasos para descargar el ZIP, abrir en Xcode e instalar en el iPhone.

## Para el desarrollador (sin Mac)

Lee **[DESARROLLADOR.md](DESARROLLADOR.md)** — push a GitHub, CI, Firebase y Render.

## Estructura

```
godot/          Proyecto Godot (abrir project.godot)
backend/        API REST en Go
docs/           Build web exportado (Firebase Hosting)
```

## Versión actual

**1.0.2** — UI profesional rediseñada, pantalla completa, cámara en misiones, permisos iOS/Android.
