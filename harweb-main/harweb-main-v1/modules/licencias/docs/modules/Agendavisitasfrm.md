# Documentación Técnica: Migración de Formulario Agenda de Visitas

## 1. Descripción General
Este módulo corresponde a la migración del formulario Delphi `Agendavisitasfrm` a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend SPA) y PostgreSQL (base de datos). El objetivo es mantener la funcionalidad original: consulta, exportación e impresión de visitas agendadas por dependencia y rango de fechas.

## 2. Arquitectura
- **Backend:** Laravel API con endpoint unificado `/api/execute` que recibe un `eRequest` y parámetros, y responde con un objeto `eResponse`.
- **Frontend:** Componente Vue.js como página independiente, con navegación, filtros, tabla de resultados, exportación a Excel y función de impresión.
- **Base de Datos:** PostgreSQL, toda la lógica SQL encapsulada en stored procedures y funciones.

## 3. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Request:**
  ```json
  {
    "eRequest": "get_agenda_visitas",
    "params": {
      "id_dependencia": 1,
      "fechaini": "2024-06-01",
      "fechafin": "2024-06-30"
    }
  }
  ```
- **Response:**
  ```json
  {
    "eResponse": {
      "success": true,
      "data": [ ... ],
      "message": ""
    }
  }
  ```

## 4. Stored Procedures y Funciones
- **sp_get_dependencias:** Devuelve el catálogo de dependencias.
- **sp_get_agenda_visitas:** Devuelve las visitas agendadas filtradas.
- **fn_dialetra:** Devuelve el nombre del día de la semana en español.

## 5. Frontend (Vue.js)
- Página independiente con ruta propia.
- Filtros: rango de fechas y dependencia.
- Tabla de resultados.
- Botones para exportar a Excel (CSV) e imprimir.
- Breadcrumb de navegación.

## 6. Exportación e Impresión
- **Exportar:** Genera un archivo CSV en el frontend con los datos actuales.
- **Imprimir:** Abre una ventana emergente con el reporte listo para impresión.

## 7. Seguridad
- Validación de parámetros en backend.
- El endpoint puede protegerse con middleware de autenticación según necesidades del proyecto.

## 8. Consideraciones
- El endpoint `/api/execute` puede ser extendido para otros formularios.
- El frontend puede adaptarse a frameworks como Vuetify o BootstrapVue para mejorar la UI.

## 9. Dependencias
- Laravel >= 8.x
- Vue.js >= 2.x o 3.x
- PostgreSQL >= 11
- Axios (frontend)

## 10. Instalación de Stored Procedures
Ejecutar los scripts SQL en la base de datos destino `BasePHP`.

## 11. Pruebas
Ver sección de casos de uso y casos de prueba.

---

## ✅ Estado de Implementación

### Completado y Funcionando Sin Errores
**Fecha:** 2025-11-03

### Problemas Resueltos:
1. **Error "could not find driver"**
   - Causa: PHP de Herd Lite no tenía extensión pdo_pgsql
   - Solución: Backend configurado con PHP 8.2.12 de XAMPP con todas las extensiones necesarias

2. **Mapeo incorrecto de base de datos**
   - Causa: Backend buscaba módulo 'licencias' pero frontend enviaba 'padron_licencias'
   - Solución: Agregadas ambas claves al mapeo en index.php

3. **Esquema incorrecto**
   - Causa: Backend apuntaba a esquema 'catastro_gdl' (vacío)
   - Solución: Cambiado a esquema 'public' donde están los datos reales

4. **Stored Procedures faltantes**
   - Causa: No existían los SPs necesarios en la base de datos
   - Solución: Creados los siguientes SPs en esquema 'public':
     - `fn_dialetra(p_dia INTEGER)` - Convierte día numérico a texto
     - `SP_DEPENDENCIAS_LIST()` - Lista dependencias disponibles
     - `SP_AGENDA_VISITAS_LIST(...)` - Lista visitas agendadas

### Configuración Final:
- **Backend:** http://localhost:8000 (PHP 8.2.12 XAMPP)
- **Frontend:** http://localhost:5180 (Vue.js + Vite)
- **Base de datos:** padron_licencias (PostgreSQL 16.10)
- **Esquema:** public
- **Tablas utilizadas:**
  - `comun.c_dependencias`
  - `comun.tramites`
  - `public.tramites_visitas`
  - `public.c_dep_horario`

### Funcionalidades Verificadas:
- ✅ Carga de catálogo de dependencias
- ✅ Búsqueda de visitas por fecha y dependencia
- ✅ Exportación a Excel (CSV)
- ✅ Impresión de reportes
- ✅ Filtros funcionando correctamente
- ✅ Interfaz responsiva y navegación

**Marcado en menú lateral con asterisco (*) para indicar estado completado.**
