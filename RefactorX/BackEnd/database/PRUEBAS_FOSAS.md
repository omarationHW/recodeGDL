# Guía de Pruebas para el Formulario de Derechos de Fosa

## Insertar datos de ejemplo

Ejecuta el siguiente comando para insertar los datos de prueba:

```bash
psql -U postgres -d multas_reglamentos -f datos_ejemplo_fosas.sql
```

O desde psql:
```sql
\i datos_ejemplo_fosas.sql
```

---

## 3 Ejemplos para probar en el formulario

### Ejemplo 1: Folio 2
**Búsqueda:** Ingresa `2` en el campo Folio y presiona "Buscar"

**Resultado esperado:**
- **ID Control:** 2
- **Cementerio:** PANTEÓN DE MEZQUITÁN
- **Clase:** PERPETUA
- **Sección:** A
- **Línea:** 3
- **Fosa:** 45
- **Titular:** MARÍA GUADALUPE PÉREZ GARCÍA
- **Período:** 2010 - 2030

---

### Ejemplo 2: Folio 7
**Búsqueda:** Ingresa `7` en el campo Folio y presiona "Buscar"

**Resultado esperado:**
- **ID Control:** 7
- **Cementerio:** PANTEÓN MUNICIPAL SAN PEDRO TLAQUEPAQUE
- **Clase:** TEMPORAL
- **Sección:** B
- **Línea:** 5
- **Fosa:** 128
- **Titular:** JOSÉ LUIS HERNÁNDEZ RODRÍGUEZ
- **Período:** 2015 - 2025

---

### Ejemplo 3: Folio 12
**Búsqueda:** Ingresa `12` en el campo Folio y presiona "Buscar"

**Resultado esperado:**
- **ID Control:** 12
- **Cementerio:** PANTEÓN DE SANTA PAULA
- **Clase:** PERPETUA
- **Sección:** C
- **Línea:** 2
- **Fosa:** 89
- **Titular:** ROBERTO CARLOS MARTÍNEZ LÓPEZ
- **Período:** 2008 - 2050

---

## Prueba adicional: Ver todas las fosas

**Búsqueda:** Ingresa `0` en el campo Folio y presiona "Buscar"

**Resultado esperado:** Debería mostrar los 3 registros anteriores (o todos los registros en la tabla)

---

## Probar desde la base de datos directamente

```sql
-- Ver todos los datos insertados
SELECT * FROM public.fosas WHERE id_control IN (2, 7, 12);

-- Probar el stored procedure
SELECT * FROM public.recaudadora_drecgo_fosa(2);
SELECT * FROM public.recaudadora_drecgo_fosa(7);
SELECT * FROM public.recaudadora_drecgo_fosa(12);
SELECT * FROM public.recaudadora_drecgo_fosa(0);  -- Todas las fosas
```

---

## Verificación en la interfaz web

1. Abre el módulo "Derechos de Fosa" en tu navegador
2. Abre las DevTools (F12) y ve a la pestaña "Network"
3. Ingresa uno de los folios de ejemplo (2, 7 o 12)
4. Presiona "Buscar"
5. Verifica en Network que el payload muestra:
   ```json
   {
     "Operacion": "RECAUDADORA_DRECGO_FOSA",
     "Base": "multas_reglamentos",
     "Esquema": "public",
     "Parametros": [{"nombre": "p_folio", "tipo": "int", "valor": 2}]
   }
   ```
6. Verifica que la respuesta contiene los datos correctos
7. Verifica que la tabla muestra la información formateada correctamente

---

## Limpiar datos de ejemplo

Si deseas eliminar los datos de prueba:

```sql
DELETE FROM public.fosas WHERE id_control IN (2, 7, 12);
```
