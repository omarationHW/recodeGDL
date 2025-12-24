# Duplicados - Reimpresión de Títulos de Propiedad

## Propósito Administrativo
Módulo para procesar solicitudes de duplicado de títulos de propiedad extraviados o deteriorados, registrando el cobro del servicio y generando la reimpresión del documento oficial.

## Funcionalidad Principal
Permite la reimpresión de títulos de propiedad previamente emitidos, registrando el pago del servicio de duplicado, validando que el título original exista, y generando una nueva impresión con marca de "DUPLICADO".

## Proceso de Negocio

### ¿Qué hace?
- Valida existencia del título original
- Registra pago de servicio de duplicado
- Recupera información del título original
- Genera reimpresión marcada como DUPLICADO
- Mantiene registro de duplicados emitidos
- Conserva datos del beneficiario original

### ¿Para qué sirve?
- Reponer títulos extraviados
- Reemplazar títulos deteriorados
- Mantener documentación vigente
- Cumplir normativa de respaldo documental

### ¿Cómo lo hace?
1. Verifica pago del servicio de duplicado
2. Busca el título original en el sistema
3. Recupera todos los datos del folio y beneficiario
4. Genera nueva impresión con leyenda "DUPLICADO"
5. Registra emisión del duplicado con fecha actual
6. Mantiene referencia al título original

## Datos y Tablas
- **ta_13_pagosrcm** - Pago de servicio de duplicado (tipo 2)
- **ta_13_titulosrcm** - Información del título original
- **ta_13_datosrcm** - Datos del espacio funerario

## Usuarios del Sistema
- Personal de Títulos
- Supervisores de Ventanilla
- Jefe de Departamento (autorización)
