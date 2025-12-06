# 🔍 Cómo Buscar Datos Reales para Pruebas

## Método 1: Ejecutar SQL en pgAdmin ⭐

1. **Abre pgAdmin**
2. **Conecta** al servidor: `192.168.20.31`
3. **Selecciona** base de datos: `padron_licencias`
4. **Abre Query Tool** (Ctrl+Shift+Q)
5. **Ejecuta** el archivo: `temp/BUSCAR_DATOS_PRUEBA.sql`

O copia y pega este SQL:

```sql
-- BUSCAR UN REQUERIMIENTO VINCULADO A UN LOCAL
SELECT
    l.id_local as "ID Local",
    a.modulo as "Módulo",
    a.folio as "Folio",
    l.nombre as "Nombre Local",
    l.oficina,
    l.num_mercado,
    a.diligencia,
    a.importe_global,
    a.fecha_emision
FROM comun.ta_11_locales l
INNER JOIN comun.ta_15_apremios a ON l.id_local = a.control_otr
LIMIT 1;
```

## Método 2: Desde el Backend Laravel

Si prefieres usar el backend, ejecuta:

```bash
php artisan tinker
```

Luego:

```php
DB::connection('pgsql')->select("
    SELECT l.id_local, a.modulo, a.folio, l.nombre
    FROM comun.ta_11_locales l
    INNER JOIN comun.ta_15_apremios a ON l.id_local = a.control_otr
    LIMIT 1
");
```

## Método 3: Script PHP Directo

Ejecuta desde el servidor (con acceso a PostgreSQL):

```bash
php temp/buscar_datos_reales.php
```

## 📋 Qué Datos Necesitas

Para probar **DatosRequerimientos** necesitas:

| Campo | Descripción | Ejemplo |
|-------|-------------|---------|
| `id_local` | ID del local | 123 |
| `modulo` | Módulo del requerimiento | 15 |
| `folio` | Folio del requerimiento | 4567 |

## ✅ Después de Obtener los Datos

Una vez que tengas los valores, prueba en el frontend:

1. Abre: `http://localhost:5173/modulos/mercados/datos-requerimientos`
2. Ingresa los valores obtenidos:
   - **ID Local:** (valor de `id_local`)
   - **Módulo:** (valor de `modulo`)
   - **Folio:** (valor de `folio`)
3. Click en **Buscar**

## 🎯 Valores de Prueba Comunes

Si no encuentras datos, estos suelen existir:

```javascript
{
  id_local: 1,
  modulo: 15,
  folio: 1
}
```

O:

```javascript
{
  id_local: 100,
  modulo: 10,
  folio: 100
}
```

## ⚠️ Importante

- Los valores deben **coincidir exactamente**
- El `id_local` debe existir en `comun.ta_11_locales`
- El par `modulo + folio + control_otr` debe existir en `comun.ta_15_apremios`
- `control_otr` debe ser igual a `id_local`

## 🔧 Troubleshooting

### Si no encuentra datos:

```sql
-- Ver cuántos locales hay
SELECT COUNT(*) FROM comun.ta_11_locales;

-- Ver cuántos requerimientos hay
SELECT COUNT(*) FROM comun.ta_15_apremios;

-- Ver cuántos están vinculados
SELECT COUNT(*)
FROM comun.ta_11_locales l
INNER JOIN comun.ta_15_apremios a ON l.id_local = a.control_otr;
```

### Si el vinculo no existe:

Prueba buscando por separado:

```sql
-- Cualquier local
SELECT * FROM comun.ta_11_locales LIMIT 1;

-- Cualquier requerimiento
SELECT * FROM comun.ta_15_apremios LIMIT 1;
```

---

**Ejecuta el SQL en pgAdmin y comparte los valores que obtengas para continuar con las pruebas.**
