# Servidores en Ejecución

## Estado de los Servidores

### ✅ Frontend (Vue.js + Vite)
- **Puerto**: 3000
- **URL**: http://localhost:3000
- **Estado**: ✅ CORRIENDO
- **Directorio**: `C:\recodeGDL_New2\RefactorX\FrontEnd`
- **Comando**: `npm run dev`
- **Task ID**: bc2d5dd

**Características:**
- Framework: Vue.js 3
- Build Tool: Vite 7.1.11
- Hot Module Replacement (HMR) activado
- Proxy configurado hacia el backend en puerto 8000

**Notas:**
- Se muestra una advertencia sobre la versión de Node.js (20.15.0 vs requerido 20.19+), pero no es crítica
- El servidor está listo en menos de 1 segundo

---

### ✅ Backend (Laravel/PHP)
- **Puerto**: 8000
- **URL**: http://127.0.0.1:8000
- **Estado**: ✅ CORRIENDO
- **Directorio**: `C:\recodeGDL_New2\RefactorX\BackEnd`
- **Comando**: `php artisan serve --port=8000`
- **Task ID**: bb9f5bf

**Características:**
- Framework: Laravel
- Base de datos: PostgreSQL
- API RESTful
- Endpoints disponibles en `/api/*`

**Notas:**
- El backend está corriendo en modo single-worker
- Se puede presionar Ctrl+C para detener el servidor

---

## Configuración

### Proxy del Frontend al Backend
El frontend está configurado para hacer proxy de todas las peticiones `/api/*` al backend:

```javascript
// vite.config.js
server: {
  port: 3000,
  proxy: {
    '/api': {
      target: 'http://127.0.0.1:8000',
      changeOrigin: true
    }
  }
}
```

Esto significa que cuando el frontend hace una petición a `http://localhost:3000/api/execute`,
automáticamente se redirige a `http://127.0.0.1:8000/api/execute`.

---

## Verificación de Estado

### Frontend
```bash
curl http://localhost:3000
# Debe retornar HTML de la aplicación Vue
```

### Backend
```bash
curl http://127.0.0.1:8000/api
# Debe retornar respuesta JSON o error de autenticación
```

---

## Cómo Detener los Servidores

### Opción 1: Usando los Task IDs
```bash
# Detener frontend
/tasks kill bc2d5dd

# Detener backend
/tasks kill bb9f5bf
```

### Opción 2: Manualmente
1. Buscar los procesos:
   ```bash
   # Windows
   netstat -ano | findstr :3000
   netstat -ano | findstr :8000

   # Matar el proceso
   taskkill /PID <PID> /F
   ```

2. O simplemente cerrar la terminal donde están corriendo

---

## Logs y Monitoreo

### Ver logs del Frontend
```bash
cat C:\Users\LUIS~1.MOL\AppData\Local\Temp\claude\C--recodeGDL-New2\tasks\bc2d5dd.output
```

### Ver logs del Backend
```bash
cat C:\Users\LUIS~1.MOL\AppData\Local\Temp\claude\C--recodeGDL-New2\tasks\bb9f5bf.output
```

---

## URLs Importantes

### Frontend
- **Aplicación Principal**: http://localhost:3000
- **Hastafrm**: http://localhost:3000/multas-reglamentos/hastafrm

### Backend
- **API Base**: http://127.0.0.1:8000/api
- **Endpoint Execute**: http://127.0.0.1:8000/api/execute

---

## Troubleshooting

### El frontend no carga
1. Verificar que el puerto 3000 no esté ocupado
2. Revisar los logs en `bc2d5dd.output`
3. Ejecutar `npm install` si faltan dependencias

### El backend no responde
1. Verificar que el puerto 8000 no esté ocupado
2. Revisar los logs en `bb9f5bf.output`
3. Verificar la conexión a la base de datos en `.env`
4. Ejecutar `composer install` si faltan dependencias

### Error de CORS
- El proxy de Vite debería manejar esto automáticamente
- Si persiste, revisar la configuración de CORS en Laravel (`config/cors.php`)

---

## Fecha de Inicio
**Fecha**: 2025-12-19
**Hora**: Aproximadamente cuando se ejecutó este documento

## Componentes Actualizados Recientemente
- ✅ Hastafrm.vue - Componente con tabla de registros
- ✅ recaudadora_hastafrm - Stored Procedure actualizado
- ✅ Base de datos multas_reglamentos - Esquema public

---

**Nota**: Ambos servidores están corriendo en segundo plano y continuarán hasta que se detengan manualmente o se cierre la sesión.
