# GuayGo — Notas para el desarrollador (sin Mac)

## Repositorio

- **GitHub:** https://github.com/SegniniJose/GuayApp
- **Código Godot:** carpeta `godot/`
- **Backend Go:** carpeta `backend/` → desplegado en Render (`https://guayapp.onrender.com`)

## Desplegar todo (desde Windows)

### 1. Subir cambios a GitHub

```powershell
cd C:\Users\Usuario\Desktop\guay-go-godot-2026-06-16
git add .
git commit -m "tu mensaje"
git push origin main
```

### 2. Builds automáticos (GitHub Actions)

| Workflow | Qué hace | Cuándo |
|----------|----------|--------|
| **Build Godot + Deploy to Firebase** | Exporta web + iOS (Linux) + Firebase Hosting | Cada push a `main` |
| **Build iOS Xcode Project (macOS)** | Exporta iOS correcto para Xcode (recomendado) | Manual: Actions → Run workflow |

Para el cliente con Mac, usa siempre el artifact del workflow **macOS**.

### 3. Generar Xcode para el cliente (manual)

1. https://github.com/SegniniJose/GuayApp/actions
2. **Build iOS Xcode Project (macOS)** → **Run workflow**
3. Cuando termine (~1 min), descarga artifact **ios-xcode-project-macos**
4. Envía el ZIP al cliente con el archivo **CLIENTE_iOS.md**

### 4. Web

- Firebase: https://guay-app-social.web.app
- Requiere secret `FIREBASE_TOKEN` en el repo para deploy automático.

### 5. Backend

- Render: https://guayapp.onrender.com
- Actualizar backend: push a `main` si tienes auto-deploy en Render, o redeploy manual en el panel de Render.

## Cambios recientes (v1.0.1)

- UI a pantalla completa en móvil.
- Cámara nativa en misiones (`CameraCapture.tscn`).
- Permisos cámara/galería en export iOS/Android.
- API apuntando a Render en producción.
