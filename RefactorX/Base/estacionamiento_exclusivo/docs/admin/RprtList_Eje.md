# Reporte: Listado de Ejecutores (Formato)

## Propósito Administrativo
Módulo de generación del formato de reporte de ejecutores fiscales. Componente que produce el documento físico con diseño oficial para listados de personal.

## Funcionalidad Principal
Genera el formato impreso del listado de ejecutores con diseño oficial, aplicando estilos, agrupaciones y formato institucional para distribución.

## Proceso de Negocio

### ¿Qué hace?
Produce el documento físico del listado de ejecutores aplicando el formato institucional, con encabezados oficiales, organización por oficina recaudadora y presentación profesional.

### ¿Para qué sirve?
- Generar documento oficial de ejecutores
- Aplicar diseño institucional
- Organizar información por oficina
- Producir listados distribuibles

### ¿Cómo lo hace?
1. Recibe datos de ejecutores del módulo llamador
2. Aplica formato oficial con logos
3. Agrupa por oficina recaudadora
4. Organiza en formato de directorio
5. Genera documento para impresión

## Datos y Tablas

### Tabla Principal
Dataset proporcionado por el módulo invocador

### Stored Procedures (SP)
No utiliza SP. Formatea datos recibidos.

### Tablas que Afecta
Módulo de solo lectura.

## Usuarios del Sistema
Invocado automáticamente por módulos de listados

## Relaciones con Otros Módulos
- **List_Eje**: Puede invocar este reporte
- **Lista_Eje**: Puede invocar este reporte
