# Instrucciones para Desplegar el SP Optimizado

## ⚠️ Problema Actual
El servidor PostgreSQL NO está corriendo, por lo que:
- El SP optimizado no se ha desplegado
- Sigue usando el SP viejo (lento con JOIN sin optimizar)
- Las peticiones tardan mucho (pending largo)

## 🔧 Solución

### Paso 1: Iniciar PostgreSQL

**Opción A - Windows Service:**
```cmd
net start postgresql-x64-14
```
O busca "Services" en Windows y inicia "PostgreSQL"

**Opción B - pgAdmin:**
Abre pgAdmin y verifica que el servidor esté corriendo

**Opción C - Instalación personalizada:**
```bash
# Busca dónde está instalado PostgreSQL
pg_ctl -D "C:\Program Files\PostgreSQL\14\data" start
```

### Paso 2: Verificar que PostgreSQL está corriendo

```bash
psql -U postgres -c "SELECT version();"
```

Si pide password, usa: `postgres` (o la que hayas configurado)

### Paso 3: Desplegar el SP Optimizado

```bash
cd C:\recodeGDL
php RefactorX/BackEnd/deploy_sp_pagalicfrm_optimized.php
```

Este script automáticamente:
- ✅ Despliega el SP optimizado
- ✅ Crea los 3 índices recomendados
- ✅ Verifica la instalación
- ✅ Muestra ejemplos de uso

### Paso 4: Probar el formulario

Después de desplegar, prueba con:
- Licencia: `100`
- Licencia: `150`
- Licencia: `200`

**Resultado esperado:** Respuesta en 0.5-1 segundo (en lugar de 10+ segundos)

---

## 🆘 Si PostgreSQL NO está instalado

Si no tienes PostgreSQL instalado o no puedes iniciarlo:

### Opción 1: Despliegue Manual con psql

```bash
psql -U postgres -d municipal_gdl -f RefactorX/Base/multas_reglamentos/database/generated/recaudadora_pagalicfrm.sql
```

### Opción 2: Despliegue Manual con pgAdmin

1. Abre pgAdmin
2. Conecta a tu servidor
3. Abre Query Tool
4. Copia y pega el contenido de `recaudadora_pagalicfrm.sql`
5. Ejecuta (F5)

### Opción 3: Usar otro cliente PostgreSQL

Si usas DBeaver, DataGrip, o similar:
1. Conecta a la base de datos `municipal_gdl`
2. Abre el archivo `recaudadora_pagalicfrm.sql`
3. Ejecuta el script

---

## 📋 Checklist de Verificación

- [ ] PostgreSQL está corriendo
- [ ] Puedes conectarte a la base de datos `municipal_gdl`
- [ ] El SP optimizado se desplegó exitosamente
- [ ] Los índices se crearon
- [ ] El formulario responde rápido (< 2 segundos)

---

## 🎯 Mejora Esperada Después del Despliegue

| Antes | Después |
|-------|---------|
| ⏱️ 10-30 segundos | ⚡ 0.5-1 segundo |
| ❌ Full table scan | ✅ Búsqueda indexada |
| 🐌 Sin cache | 🚀 Con cache |
| 😤 Usuario frustrado | 😊 Usuario feliz |

---

## ⚠️ Solución Temporal (Frontend)

Mientras no se despliegue el SP, el frontend ahora tiene:
- ✅ Timeout de 10 segundos
- ✅ Mensaje claro si tarda mucho
- ✅ Validación de campo obligatorio

**Pero la solución REAL es desplegar el SP optimizado.**

---

## 📞 ¿Necesitas Ayuda?

Si no puedes iniciar PostgreSQL o desplegar el SP:

1. Verifica que PostgreSQL esté instalado:
   ```bash
   psql --version
   ```

2. Busca el puerto de PostgreSQL:
   ```bash
   netstat -an | findstr 5432
   ```

3. Verifica el servicio en Windows:
   ```bash
   sc query postgresql-x64-14
   ```
