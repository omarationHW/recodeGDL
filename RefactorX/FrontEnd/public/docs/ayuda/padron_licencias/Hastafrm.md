# Selector de Bimestre y Año (Hasta)

## Descripción General

### ¿Qué hace este módulo?
Es un **diálogo modal simple** que permite al usuario seleccionar un bimestre (1-6) y un año para establecer un período límite en operaciones de pagos o consultas. Se usa como ventana auxiliar en otros módulos.

### ¿Para qué sirve en el proceso administrativo?
- Capturar período límite para cálculos de pagos
- Definir hasta qué bimestre/año se deben considerar adeudos
- Establecer punto de corte temporal en reportes
- Validar períodos fiscales en operaciones masivas

### ¿Quiénes lo utilizan?
Es un componente auxiliar usado por otros módulos, no se ejecuta directamente por usuarios. Se invoca desde:
- Módulos de pagos
- Módulos de reportes de adeudos
- Cálculos de saldos por período

## Proceso Administrativo

**Captura de Datos:**
1. Sistema abre ventana modal (ShowModal)
2. Usuario captura:
   - **Bimestre**: Campo Edit1 (1 a 6)
   - **Año**: Campo Edit2 (ej: 2025)
3. Presiona "Aceptar" o "Cancelar"

**Validaciones Automáticas:**
- **Bimestre**: Solo permite dígitos 1-6
  - Si se captura otro valor, muestra mensaje y marca como inválido
- **Año**: Debe ser >= 1970
  - Si es menor, muestra mensaje y marca como inválido

**Salida:**
- Si "Aceptar" y datos válidos: ModalResult = mrOK
- Si "Cancelar" o datos inválidos: ModalResult = mrCancel
- Los valores se leen desde Edit1 y Edit2 por el módulo llamador

## Tablas de Base de Datos

### No usa tablas
Este módulo NO accede a base de datos. Es solo una interfaz de captura.

## Stored Procedures
No utiliza stored procedures.

## Impacto y Repercusiones

### ¿Qué registros afecta?
**NINGUNO** - No modifica datos, solo captura valores

### ¿Qué cambios de estado provoca?
**NINGUNO** - Es un selector/capturador de datos

### ¿Qué documentos genera?
**NINGUNO** - Solo retorna valores al módulo llamador

### ¿Qué validaciones aplica?

**Validación de Bimestre:**
```pascal
- Al capturar: Solo permite dígitos 1-6
- Al presionar Enter: Avanza a campo año
- Al Aceptar:
  IF bimestre <= 0 OR bimestre > 6 THEN
     Marca Edit1.Text = '9' (inválido)
     Mensaje: "Bimestre inválido!"
     ModalResult = mrCancel
```

**Validación de Año:**
```pascal
- Al Aceptar:
  IF año < 1970 THEN
     Marca Edit2.Text = '9999' (inválido)
     Mensaje: "Año inválido!"
     ModalResult = mrCancel
```

## Flujo de Trabajo

```
1. Módulo llamador invoca: frmhasta.ShowModal
2. FormShow se ejecuta:
   - Edit1.Text = '' (limpia bimestre)
   - Edit2.Text = '' (limpia año)
   - Edit1.SetFocus (cursor en bimestre)
3. Usuario captura bimestre (1-6)
4. Presiona Enter o Tab
5. Usuario captura año (ej: 2025)
6. ¿Presiona qué botón?

   ACEPTAR (BitBtn1):
   - Valida bimestre: 1-6
   - Si inválido:
     * Edit1 = '9', Edit2 = '9999'
     * Mensaje error
     * ModalResult = mrCancel
   - Valida año: >= 1970
   - Si inválido:
     * Edit1 = '9', Edit2 = '9999'
     * Mensaje error
     * ModalResult = mrCancel
   - Si ambos válidos:
     * ModalResult = mrOK
     * Cierra ventana

   CANCELAR (BitBtn2):
   - Edit1.Text = '9'
   - Edit2.Text = '9999'
   - ModalResult = mrCancel
   - Cierra ventana

7. Módulo llamador lee resultado:
   IF ModalResult = mrOK THEN
      bim := StrToInt(frmhasta.Edit1.Text)
      año := StrToInt(frmhasta.Edit2.Text)
      // Usa valores
   ELSE
      // Operación cancelada

8. FIN
```

## Notas Importantes

### Consideraciones Especiales

**1. Valores Especiales de Cancelación**
- Edit1.Text = '9' significa operación cancelada
- Edit2.Text = '9999' significa operación cancelada
- El módulo llamador debe verificar estos valores

**2. Bimestres Fiscales**
- Bimestre 1: Enero-Febrero
- Bimestre 2: Marzo-Abril
- Bimestre 3: Mayo-Junio
- Bimestre 4: Julio-Agosto
- Bimestre 5: Septiembre-Octubre
- Bimestre 6: Noviembre-Diciembre

**3. Año Mínimo**
- Valida >= 1970 (probablemente fecha de creación del sistema)
- Protege contra capturas erróneas de años muy antiguos

**4. Módulo Modal**
- Se ejecuta con ShowModal (bloquea ventana padre)
- Debe cerrarse antes de continuar proceso
- No permite interactuar con otras ventanas mientras está abierta

**5. Sin Valores Default**
- Siempre inicia con campos vacíos
- Usuario debe capturar explícitamente
- No sugiere período actual

### Restricciones
- Solo acepta bimestres 1-6
- Solo acepta años >= 1970
- No permite omitir campos (ambos son obligatorios)
- Campos son texto (MaskEdit) que se convierten a enteros

### Uso Típico en Código Llamador

```pascal
// Ejemplo de uso
var
  bimestre, año: Integer;
begin
  frmhasta := Tfrmhasta.Create(Self);
  try
    if frmhasta.ShowModal = mrOK then
    begin
      // Obtener valores
      bimestre := StrToInt(frmhasta.Edit1.Text);
      año := StrToInt(frmhasta.Edit2.Text);

      // Usar valores para cálculos
      CalcularAdeudoHasta(bimestre, año);
    end
    else
    begin
      // Usuario canceló
      ShowMessage('Operación cancelada');
    end;
  finally
    frmhasta.Free;
  end;
end;
```

### Mejoras Potenciales
- Agregar valor default del período actual
- Calendario desplegable para seleccionar año
- Validación del año <= año actual
- Mostrar descripción del bimestre seleccionado
