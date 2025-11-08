# Impresión de Recibos

## Descripción General

### ¿Qué hace este módulo?
Este módulo permite generar e imprimir recibos oficiales de pago por conceptos específicos relacionados con el trámite de licencias y anuncios. Los recibos se emiten principalmente para documentar el pago de constancias y certificaciones solicitadas por los contribuyentes.

### ¿Para qué sirve en el proceso administrativo?
- Formaliza la recepción de pagos mediante documentos oficiales
- Proporciona comprobante fiscal al contribuyente
- Genera registro documental de las transacciones realizadas
- Facilita la auditoría y control de ingresos municipales

### ¿Quiénes lo utilizan?
- Personal de ventanilla de Padrón y Licencias
- Cajeros que procesan pagos
- Personal administrativo autorizado para emitir constancias
- Contribuyentes que reciben el comprobante de pago

## Proceso Administrativo

### ¿Cómo funciona el proceso paso a paso?

1. **Captura del número de licencia**
   - El usuario ingresa el número de licencia en el campo correspondiente
   - Presiona ENTER para buscar la licencia en el sistema

2. **Validación de la licencia**
   - El sistema busca la licencia en la base de datos
   - Si existe, habilita el botón de impresión
   - Si no existe, muestra mensaje: "No se encontró licencia con ese número"

3. **Selección del tipo de documento**
   - El usuario selecciona el tipo de recibo a imprimir:
     - Constancia
     - Certificación

4. **Generación del recibo**
   - El sistema obtiene el costo del parámetro configurado (costo_certific)
   - Convierte el monto numérico a texto (letras)
   - Genera el recibo con los datos de la licencia
   - Envía a impresión

5. **Cierre del proceso**
   - Después de imprimir, se deshabilita el botón de impresión
   - Se cierra la consulta de la licencia

### ¿Qué información requiere el usuario?
- **Número de licencia** (obligatorio): Identificador único de la licencia a la que corresponde el pago
- **Tipo de documento**: Selección entre Constancia o Certificación

### ¿Qué validaciones se realizan?
1. **Existencia de licencia**: Verifica que el número de licencia ingresado exista en el sistema
2. **Formato de entrada**: Solo acepta valores numéricos para el número de licencia
3. **Costo configurado**: Obtiene el monto del pago desde la tabla de parámetros del sistema

### ¿Qué documentos genera?
- **Recibo oficial de pago** que incluye:
  - Logotipo institucional
  - Número de licencia
  - Datos del contribuyente
  - Concepto del pago (Constancia o Certificación)
  - Monto en números
  - Monto con letra
  - Fecha de emisión

## Tablas de Base de Datos

### Tabla Principal
**licencias**
- Contiene la información completa de las licencias registradas en el sistema
- Se consulta para obtener los datos del titular que aparecerán en el recibo

### Tablas Relacionadas

#### Tablas que Consulta:
- **licencias**: Obtiene información del número de licencia y datos asociados
- **parametros_lic**: Consulta el costo configurado para certificaciones (campo: costo_certific)

#### Tablas que Modifica:
- Ninguna. Este módulo es de solo consulta e impresión, no modifica registros en la base de datos.

## Stored Procedures
Este módulo no utiliza stored procedures. Realiza consultas directas mediante queries parametrizadas.

## Impacto y Repercusiones

### ¿Qué registros afecta?
Ninguno. Este módulo es exclusivamente de consulta e impresión. No realiza modificaciones en la base de datos.

### ¿Qué cambios de estado provoca?
No provoca cambios de estado en ningún registro. Es un proceso de solo lectura.

### ¿Qué documentos/reportes genera?
1. **Recibo oficial de pago**
   - Documento impreso en formato oficial
   - Contiene membrete institucional
   - Incluye datos de la licencia consultada
   - Muestra el concepto (Constancia o Certificación)
   - Presenta el monto en números y letra
   - Fecha de emisión automática

### ¿Qué validaciones de negocio aplica?
1. **Validación de existencia**: Solo permite imprimir recibos para licencias que existen en el sistema
2. **Prevención de duplicados**: Deshabilita el botón de impresión después de generar el recibo
3. **Monto parametrizado**: El costo se obtiene de una tabla de parámetros centralizada, asegurando uniformidad en los cobros

## Flujo de Trabajo

```
INICIO
  ↓
Ingreso de número de licencia
  ↓
Presionar ENTER
  ↓
¿Existe la licencia? → NO → Mostrar mensaje de error
  ↓ SÍ                      ↓
Habilitar botón imprimir    Retornar a captura
  ↓
Seleccionar tipo (Constancia/Certificación)
  ↓
Clic en botón "Imprimir"
  ↓
Obtener costo desde parámetros
  ↓
Convertir monto a texto
  ↓
Generar recibo con datos completos
  ↓
Enviar a impresora
  ↓
Deshabilitar botón impresión
  ↓
Cerrar consulta de licencia
  ↓
FIN
```

## Notas Importantes

### Consideraciones especiales
1. **Control de impresión**: El sistema deshabilita el botón de impresión después de generar un recibo para evitar duplicados accidentales
2. **Fuente de costos**: El monto del recibo se obtiene automáticamente de la tabla de parámetros, no se captura manualmente
3. **Formato de salida**: Los recibos incluyen conversión automática del monto a texto (con letra)
4. **Validación en tiempo real**: La búsqueda de licencias se realiza al presionar ENTER, proporcionando retroalimentación inmediata

### Restricciones
1. Solo se puede imprimir recibos para licencias que existen en el sistema
2. El costo es fijo y se obtiene de parámetros del sistema (no editable desde este módulo)
3. Después de imprimir, es necesario cambiar de licencia para habilitar nuevamente la impresión
4. El tipo de documento (Constancia/Certificación) debe seleccionarse antes de imprimir

### Permisos necesarios
- Acceso al módulo de Padrón y Licencias
- Permisos de impresión en el sistema
- Acceso de lectura a las tablas:
  - licencias
  - parametros_lic

### Recomendaciones de uso
1. Verificar que la impresora esté configurada y lista antes de iniciar el proceso
2. Confirmar que el número de licencia sea correcto antes de imprimir
3. Seleccionar cuidadosamente el tipo de documento (Constancia vs Certificación)
4. Conservar copia del recibo impreso para archivo
5. Si se requiere reimprimir, es necesario volver a capturar el número de licencia
