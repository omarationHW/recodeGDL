# Nota sobre Mapeo de Tablas - Cementerios

**Fecha:** 2025-11-26
**Base de Datos:** cementerio

---

## Análisis de Tablas Requeridas vs Existentes

### Tablas Requeridas por los SPs Migrados

Los stored procedures migrados hacen referencia a las siguientes tablas:

1. **titulos** - Referenciada por `sp_cem_reporte_titulos`
2. **bonificaciones** - Referenciada por `sp_cem_reporte_bonificaciones`
3. **datosrcm** - Referenciada por `sp_cem_reporte_bonificaciones` y `sp_cem_reporte_cuentas_cobrar`
4. **ta_12_passwords** - Referenciada por `sp_validar_usuario` y `sp_cambiar_password`
5. **usuarios** - Referenciada por `sp_cem_reporte_bonificaciones`

---

## Tablas Existentes en cementerio.public

Las siguientes tablas existen en la base de datos:

```
cg_poliza_movimientos
cg_polizas
ta_12_depositos
ta_12_nombrerec
ta_13_adeudosrcm
ta_13_bonifica
ta_13_bonifrcm
ta_13_cem400
ta_13_datosrcmadic
ta_13_datosrcmhis
ta_13_datosrcmextra
ta_13_descpens
ta_13_descrec
ta_13_descuentos
ta_13_duplicarcm
ta_13_medidas
ta_13_pagosrcm
ta_13_rcmcuotas
ta_13_recargosrcm
ta_13_titextra
ta_13_titulos
tc_13_cementerios
```

---

## Mapeo de Tablas Detectado

Basándose en las convenciones de nomenclatura, se detecta el siguiente mapeo probable:

| Tabla Esperada | Tabla Real en DB | Estado | Observaciones |
|----------------|------------------|--------|---------------|
| titulos | ta_13_titulos | ✓ EXISTE | Prefijo ta_13_ |
| bonificaciones | ta_13_bonifica o ta_13_bonifrcm | ⚠ VERIFICAR | Dos posibles candidatas |
| datosrcm | ta_13_datosrcmhis o ta_13_datosrcmadic | ⚠ VERIFICAR | Múltiples variantes |
| ta_12_passwords | ❌ NO EXISTE | ✗ FALTA | No encontrada |
| usuarios | ❌ NO EXISTE | ✗ FALTA | No encontrada |

---

## Acciones Requeridas

### 1. Actualizar SPs con Nombres Correctos de Tablas

Los SPs necesitan ser actualizados para usar los nombres reales de las tablas en la BD:

#### sp_cem_reporte_titulos
```sql
-- Cambiar:
FROM titulos t
-- Por:
FROM ta_13_titulos t
```

#### sp_cem_reporte_bonificaciones
```sql
-- Cambiar:
FROM bonificaciones b
-- Por:
FROM ta_13_bonifica b  -- o ta_13_bonifrcm (verificar cuál es la correcta)

-- Cambiar:
LEFT JOIN datosrcm d
-- Por:
LEFT JOIN ta_13_datosrcmhis d  -- o ta_13_datosrcmadic (verificar estructura)
```

#### sp_cem_reporte_cuentas_cobrar
```sql
-- Cambiar:
FROM datosrcm d
-- Por:
FROM ta_13_datosrcmhis d  -- o ta_13_datosrcmadic (verificar estructura)
```

---

### 2. Crear o Identificar Tablas Faltantes

#### ta_12_passwords
Esta tabla no existe. Opciones:
- Crearla si es necesaria
- Usar una tabla existente de autenticación
- Eliminar los SPs de autenticación si no se usan

#### usuarios
Esta tabla no existe. Opciones:
- Crearla si es necesaria
- Usar una tabla de usuarios de otro esquema/BD
- Modificar el SP para no depender de esta tabla

---

### 3. Verificar Estructura de Tablas

Antes de actualizar los SPs, verificar la estructura de las tablas candidatas:

```sql
-- Verificar estructura de ta_13_titulos
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'ta_13_titulos'
ORDER BY ordinal_position;

-- Verificar estructura de ta_13_bonifica
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'ta_13_bonifica'
ORDER BY ordinal_position;

-- Verificar estructura de ta_13_bonifrcm
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'ta_13_bonifrcm'
ORDER BY ordinal_position;

-- Verificar estructura de ta_13_datosrcmhis
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'ta_13_datosrcmhis'
ORDER BY ordinal_position;

-- Verificar estructura de ta_13_datosrcmadic
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'ta_13_datosrcmadic'
ORDER BY ordinal_position;
```

---

### 4. Determinar Tabla de Bonificaciones

Existen dos candidatas:
- **ta_13_bonifica** - Posiblemente tabla principal de bonificaciones
- **ta_13_bonifrcm** - Posiblemente bonificaciones específicas de RCM

Ejecutar:
```sql
SELECT * FROM ta_13_bonifica LIMIT 5;
SELECT * FROM ta_13_bonifrcm LIMIT 5;
```

Y comparar estructuras para determinar cuál usar.

---

### 5. Determinar Tabla de Datos RCM

Existen tres candidatas:
- **ta_13_datosrcmhis** - Posiblemente histórico de datos RCM
- **ta_13_datosrcmadic** - Posiblemente datos adicionales RCM
- **ta_13_datosrcmextra** - Posiblemente datos extra RCM

La más probable para el SP de reportes es **ta_13_datosrcmhis** (histórico).

---

## Estado Actual de los SPs

⚠ **ADVERTENCIA:** Los SPs están creados pero **NO FUNCIONARÁN** hasta que se actualicen con los nombres correctos de las tablas.

### SPs Afectados:
1. `sp_cem_reporte_titulos` - Requiere cambiar `titulos` → `ta_13_titulos`
2. `sp_cem_reporte_bonificaciones` - Requiere cambiar `bonificaciones` → `ta_13_bonifica` y `datosrcm` → `ta_13_datosrcmhis`
3. `sp_cem_reporte_cuentas_cobrar` - Requiere cambiar `datosrcm` → `ta_13_datosrcmhis`
4. `sp_validar_usuario` - Requiere cambiar `ta_12_passwords` → tabla real o crear tabla
5. `sp_cambiar_password` - Requiere cambiar `ta_12_passwords` → tabla real o crear tabla

---

## Próximos Pasos Recomendados

1. **Verificar estructuras de tablas** (queries arriba)
2. **Determinar mapeo correcto** (especialmente bonificaciones y datosrcm)
3. **Actualizar SPs con nombres correctos**
4. **Decidir sobre ta_12_passwords y usuarios** (crear o usar existente)
5. **Probar SPs con datos reales**
6. **Actualizar reporte de migración**

---

**Fin de la nota**
