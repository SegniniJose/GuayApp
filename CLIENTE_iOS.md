# GuayGo — Instalar en iPhone (para el cliente con Mac)

Esta guía es para quien tenga **Mac + Xcode** y quiera probar la app en un iPhone real.

## 1. Descargar el proyecto Xcode

1. Entra a: **https://github.com/SegniniJose/GuayApp/actions**
2. Abre el workflow **"Build iOS Xcode Project (macOS)"** (el más reciente en verde).
3. Baja hasta **Artifacts** y descarga **`ios-xcode-project-macos`** (archivo ZIP).

   Alternativa (web + backend ya desplegados):
   - Web: **https://guay-app-social.web.app**
   - API: **https://guayapp.onrender.com**

## 2. Descomprimir

Descomprime el ZIP. Dentro verás una carpeta con el proyecto Xcode (`.xcodeproj`, `guay-go-godot.pck`, frameworks, etc.).

## 3. Abrir en Xcode

1. Abre **Xcode** en el Mac.
2. **File → Open** y selecciona el archivo **`.xcodeproj`** dentro de la carpeta descomprimida.
3. En la barra superior, elige tu **iPhone** conectado por cable (o un simulador).

## 4. Configurar firma (Signing)

1. En el panel izquierdo, clic en el proyecto (icono azul).
2. Pestaña **Signing & Capabilities**.
3. Marca **Automatically manage signing**.
4. Elige tu **Team** (cuenta Apple Developer).
5. Si el Bundle ID `com.guayago.test` da conflicto, cámbialo por uno único (ej. `com.tuempresa.guaygo.test`).

## 5. Compilar e instalar

1. Pulsa **▶ Run** (o `Cmd + R`).
2. Si el iPhone pide **confiar en el desarrollador**: Ajustes → General → VPN y gestión de dispositivos → Confiar.
3. La primera vez que uses la **cámara**, acepta el permiso.

## 6. Qué probar (versión 1.0.2)

- Registro e inicio de sesión.
- Pantalla **a pantalla completa** (ya no se ve pequeña).
- **Nueva interfaz** más legible (Dashboard, Login, barra de navegación).
- Misiones → tocar para subir foto → debe abrirse la **cámara** (botón **Galería** si prefieres una foto guardada).
- Amigos, ligas, chat y ranking según el plan de pruebas.

## Problemas frecuentes

| Problema | Qué hacer |
|----------|-----------|
| Error de firma / provisioning | Revisa Team en Signing y que el iPhone esté en tu cuenta de desarrollador. |
| App no instala | Desinstala la versión anterior de GuayGo e intenta de nuevo. |
| Login falla | Espera ~30 s (el servidor gratis en Render puede estar despertando) e intenta otra vez. |
| Cámara no abre | Ajustes → GuayGo → activar **Cámara** y **Fotos**. |

## Contacto

Si algo falla, envía captura de pantalla y el paso exacto donde ocurre.
