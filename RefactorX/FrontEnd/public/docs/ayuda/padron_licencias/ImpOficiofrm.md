# Selector de Tipo de Oficio a Imprimir

## Descripción General

### ¿Qué hace este módulo?
Es un **diálogo modal de selección** que permite al usuario elegir qué tipo de oficio desea imprimir en el proceso de trámites. Se usa como ventana auxiliar para determinar el formato de documento a generar.

### ¿Para qué sirve en el proceso administrativo?
- Seleccionar el formato de oficio a generar para un trámite
- Permitir flexibilidad en los documentos oficiales
- Controlar qué tipo de comunicado se enviará a dependencias o contribuyentes
- Diferenciar entre diferentes formatos de oficios según el proceso

### ¿Quiénes lo utilizan?
Es un componente auxiliar invocado desde el módulo **regsolicfrm** (Registro de Solicitudes). No se ejecuta directamente por usuarios.

## Proceso Administrativo

**1. Invocación**
- Módulo principal (regsolicfrm) invoca esta ventana modal
- Se ejecuta con ShowModal (bloquea ventana padre)

**2. Selección**
- Usuario selecciona una de 4 opciones en RadioGroup1:
  - **Opción 0**: Oficio tipo 1
  - **Opción 1**: Oficio tipo 2
  - **Opción 2**: Oficio tipo 3
  - **Opción 3**: Oficio tipo 4
- Cada opción representa un formato diferente de oficio

**3. Confirmación o Cancelación**
- **BitBtn1 (Aceptar)**:
  - Asigna valor seleccionado a variable global `imprimeOficio`
  - Cierra ventana
- **BitBtn2 (Cancelar)**:
  - Asigna 0 a variable `imprimeOficio`
  - Cierra ventana

**4. Retorno al Módulo Principal**
- El módulo llamador lee la variable `imprimeOficio`
- Según el valor (1, 2, 3, 4 o 0), imprime el formato correspondiente

## Tablas de Base de Datos

### No usa tablas
Este módulo NO accede a base de datos. Solo captura selección del usuario.

## Stored Procedures
No utiliza stored procedures.

## Impacto y Repercusiones

### ¿Qué registros afecta?
**NINGUNO** - No accede ni modifica base de datos

### ¿Qué cambios de estado provoca?
**NINGUNO** - Solo retorna un valor de selección

### ¿Qué documentos genera?
**NINGUNO directamente** - El módulo llamador genera el documento según la selección

### ¿Qué validaciones aplica?
- **Selección obligatoria**: Debe seleccionar una opción del RadioGroup
- Si cancela: imprimeOficio = 0 (indica cancelación)

## Flujo de Trabajo

```
1. Módulo regsolicfrm invoca:
   frmImpOficio.ShowModal

2. Ventana se abre con RadioGroup1
   - Muestra 4 opciones de tipos de oficio

3. Usuario selecciona una opción (itemindex 0-3)

4. ¿Qué botón presiona?

   ACEPTAR (BitBtn1Click):
   - CASE radiogroup1.itemindex OF
       0: imprimeOficio := 1
       1: imprimeOficio := 2
       2: imprimeOficio := 3
       3: imprimeOficio := 4
     END
   - Close (cierra ventana)

   CANCELAR (BitBtn2Click):
   - imprimeOficio := 0
   - Close (cierra ventana)

5. Control regresa a regsolicfrm

6. regsolicfrm lee variable imprimeOficio:
   CASE imprimeOficio OF
     0: // Cancelado, no imprime
     1: // Imprime oficio tipo 1
     2: // Imprime oficio tipo 2
     3: // Imprime oficio tipo 3
     4: // Imprime oficio tipo 4
   END

7. FIN
```

## Notas Importantes

### Consideraciones Especiales

**1. Variable Global**
```pascal
// En unit regsolicfrm:
var
  imprimeOficio: Integer;
```
- Es una variable global definida en el módulo llamador
- Se usa para comunicar la selección
- Valor 0 = cancelado/sin selección
- Valores 1-4 = tipos de oficio

**2. Tipos de Oficio (dependen del contexto)**
Los tipos específicos de oficio varían según el módulo llamador, pero comúnmente son:
- **Tipo 1**: Oficio de solicitud de revisión a dependencia
- **Tipo 2**: Oficio de notificación al contribuyente
- **Tipo 3**: Oficio de respuesta o dictamen
- **Tipo 4**: Oficio especial o formato alternativo

**3. Modal y Bloqueo**
- ShowModal bloquea la ventana padre
- Usuario debe cerrar esta ventana para continuar
- No permite interacción con otras ventanas

**4. Sin Valores Default**
- RadioGroup no tiene selección inicial
- Usuario debe seleccionar explícitamente
- Si no selecciona y presiona Aceptar, toma el primer item (0)

### Restricciones
- Debe usarse desde regsolicfrm o módulo compatible
- Requiere variable global imprimeOficio definida
- No tiene funcionalidad independiente

### Uso Típico

```pascal
// En módulo regsolicfrm
procedure TfrmRegsolic.GenerarOficio;
var
  tipoOficio: Integer;
begin
  // Abrir selector
  frmImpOficio := TfrmImpOficio.Create(Self);
  try
    frmImpOficio.ShowModal;

    // Leer selección
    tipoOficio := imprimeOficio;

    // Procesar según tipo
    case tipoOficio of
      0: ShowMessage('Impresión cancelada');
      1: ImprimirOficioTipo1;
      2: ImprimirOficioTipo2;
      3: ImprimirOficioTipo3;
      4: ImprimirOficioTipo4;
    end;
  finally
    frmImpOficio.Free;
  end;
end;
```

### Mejoras Potenciales
- Agregar descripción de cada tipo de oficio en el RadioGroup
- Mostrar vista previa del formato seleccionado
- Permitir configurar tipos de oficio sin recompilar
- Agregar validación de selección obligatoria antes de aceptar
- Guardar última selección como default para próxima vez
