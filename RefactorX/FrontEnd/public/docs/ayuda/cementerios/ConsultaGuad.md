# ConsultaGuad - Consulta de Panteón Guadalajara

## Propósito Administrativo
Módulo de consulta especializado para visualizar y buscar registros de espacios funerarios ubicados específicamente en el Panteón Municipal de Guadalajara.

## Funcionalidad Principal
Permite realizar búsquedas y consultas filtradas de espacios funerarios del Panteón Guadalajara, mostrando información de ubicación, concesionarios, pagos y adeudos, con capacidad de generar reportes específicos de este cementerio.

## Proceso de Negocio

### ¿Qué hace?
- Filtra automáticamente registros del Panteón Guadalajara
- Permite búsqueda por clase, sección, línea, fosa
- Muestra listado de espacios con datos de concesionarios
- Presenta información de pagos y adeudos
- Genera reportes específicos del panteón
- Permite consultas por rangos de ubicación
- Muestra estado de ocupación del panteón

### ¿Para qué sirve?
- Administración específica del Panteón Guadalajara
- Control de ocupación y disponibilidad
- Reportes administrativos por panteón
- Estadísticas específicas del cementerio
- Atención de consultas de usuarios de ese panteón

### ¿Cómo lo hace?
1. Abre con filtro pre configurado: cementerio="GUAD"
2. Presenta formulario de búsqueda con criterios de ubicación
3. Usuario puede buscar por:
   - Clase (Primera, Segunda, Tercera)
   - Sección (número y letra)
   - Línea (número y letra)
   - Fosa (número y letra)
   - Nombre de concesionario
4. Muestra resultados en grid con información resumida
5. Permite seleccionar registro para ver detalle completo
6. Genera reportes personalizados del Panteón Guadalajara

### ¿Qué necesita para funcionar?
- Acceso a ta_13_datosrcm con filtro de cementerio
- Permisos de consulta
- Identificador del panteón: "GUAD"

## Datos y Tablas

### Tabla Principal
**ta_13_datosrcm** - Filtrada por cementerio="GUAD"

### Tablas Relacionadas
- ta_13_pagosrcm - Historial de pagos
- ta_13_adeudosrcm - Adeudos pendientes
- ta_cementerios - Datos del Panteón Guadalajara

## Usuarios del Sistema
- Administradores del Panteón Guadalajara
- Personal de estadística
- Personal de ventanilla
- Directivos para reportes gerenciales

## Relaciones con Otros Módulos
- Similar a ConsultaMezq, ConsultaSAndres, ConsultaJardin
- Alimenta reportes específicos por panteón
- Base para estadísticas del Panteón Guadalajara
