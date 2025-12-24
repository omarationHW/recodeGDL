# Selección de Documentos Requeridos

## Descripción General

### ¿Qué hace este módulo?
Este módulo permite seleccionar mediante checkboxes los documentos que el contribuyente debe presentar para un trámite de licencia. Funciona como una ventana de diálogo donde se marcan los requisitos documentales necesarios según el tipo de trámite.

### ¿Para qué sirve en el proceso administrativo?
- Define la lista de documentos requeridos para un trámite
- Permite seleccionar de un catálogo predefinido de documentos comunes
- Facilita captura personalizada de documentos especiales
- Genera texto con todos los documentos marcados
- Estandariza requisitos documentales
- Almacena temporalmente la lista de documentos

### ¿Quiénes lo utilizan?
- Personal de ventanilla que captura trámites
- Personal de Padrón y Licencias que registra solicitudes
- Personal que revisa documentación
- Supervisores que definen requisitos

## Proceso Administrativo

### ¿Cómo funciona el proceso paso a paso?

1. **Apertura del módulo**
   - Sistema muestra ventana con 19 checkboxes
   - Cada checkbox representa un tipo de documento común
   - Todos los checkboxes inician desmarcados

2. **Selección de documentos estándar**
   - Usuario marca checkboxes de documentos que aplican
   - Documentos disponibles (19 opciones):
     - CheckBox1 a CheckBox19: Documentos predefinidos
     - CheckBox21: "Otros" (permite texto libre)

3. **Captura de documento especial (CheckBox21)**
   - Si usuario marca CheckBox21 ("Otros"):
     - Sistema muestra campo Edit1
     - Usuario puede capturar texto libre
   - Si usuario desmarca CheckBox21:
     - Sistema oculta campo Edit1

4. **Confirmación de selección**
   - Usuario presiona botón "Aceptar" (Button1)

5. **Construcción de lista de documentos**
   - Sistema recorre todos los checkboxes marcados
   - Por cada checkbox activo:
     - Concatena su caption a variable doctos
   - Si CheckBox21 está marcado:
     - Agrega el texto de Edit1

6. **Almacenamiento temporal**
   - Lista completa se guarda en variable doctos
   - Variable es accesible desde módulo padre (regsolicfrm)

7. **Cierre del módulo**
   - Usuario confirma, sistema cierra ventana
   - Módulo padre usa variable doctos para guardar en BD

#### CANCELACIÓN

1. **Usuario cancela**
   - Presiona botón "Cancelar" (Button2)

2. **Limpieza de datos**
   - Sistema limpia variable doctos = ''
   - Descarta selecciones

3. **Cierre**
   - Sistema cierra ventana
   - Módulo padre detecta doctos vacío y no guarda nada

### ¿Qué información requiere el usuario?

**Datos obligatorios:**
- **Selección de checkboxes**: Al menos un documento debe marcarse

**Datos opcionales:**
- **Texto libre en Edit1**: Solo si se marca "Otros" (CheckBox21)

### ¿Qué validaciones se realizan?

1. **Sin validación de mínimo**
   - Sistema no requiere que se marque al menos un checkbox
   - Permite confirmar sin selecciones (doctos quedaría vacío)

2. **Visibilidad de Edit1**
   - Edit1 solo visible si CheckBox21 está marcado
   - Oculto automáticamente si se desmarca

3. **Concatenación de textos**
   - Cada checkbox agrega su caption a la cadena
   - No hay separadores explícitos entre documentos

### ¿Qué documentos genera?
Ninguno. Este módulo genera una cadena de texto con la lista de documentos requeridos.

## Tablas de Base de Datos

### Tablas que Consulta
**Ninguna**. Este módulo no accede a base de datos.

### Tablas que Modifica
**Ninguna**. Solo trabaja con variables en memoria.

## Stored Procedures
No utiliza stored procedures.

## Impacto y Repercusiones

### ¿Qué registros afecta?

**En memoria (temporal):**
1. **Variable doctos** (tipo String)
   - Definida en módulo padre (regsolicfrm)
   - Almacena concatenación de todos los documentos marcados
   - Es usada posteriormente por módulo padre

**En base de datos (posterior):**
- El módulo padre (regsolicfrm) guarda el contenido de doctos en:
  - Tabla tramites, campo documentos (tipo Memo)
  - Asociado al trámite que se está registrando

### ¿Qué cambios de estado provoca?

**Ninguno directamente**. Este módulo solo:
1. Permite seleccionar documentos
2. Construye cadena de texto
3. La almacena en variable temporal

El módulo padre es quien posteriormente guarda en BD.

### ¿Qué documentos/reportes genera?
Ninguno.

### ¿Qué validaciones de negocio aplica?

1. **Estandarización de requisitos**
   - Presenta catálogo común de documentos
   - Facilita consistencia en requisitos

2. **Flexibilidad para casos especiales**
   - Opción "Otros" permite documentos no estándar
   - Adapta a necesidades particulares

## Flujo de Trabajo

```
INICIO
  ↓
Mostrar ventana con checkboxes
  ↓
Usuario marca checkboxes de documentos requeridos
  ↓
¿Marca CheckBox21 (Otros)? → SÍ → Mostrar Edit1
  ↓ NO                              Usuario captura texto
Continuar
  ↓
¿Usuario presiona botón?
  ↓
┌─────────────┬──────────────┐
│  Aceptar    │  Cancelar    │
└─────────────┴──────────────┘
      ↓              ↓
Construir lista  Limpiar doctos
doctos = ''      doctos = ''
      ↓              ↓
Para cada checkbox:
  ¿Está marcado? → SÍ → doctos += caption
  ↓ NO
Siguiente checkbox
      ↓
¿CheckBox21 marcado? → SÍ → doctos += Edit1.text
  ↓ NO
      ↓
Cerrar ventana
      ↓
FIN
```

## Notas Importantes

### Consideraciones especiales

1. **Catálogo predefinido**
   - 19 opciones de documentos comunes
   - Opción 21 para casos especiales
   - Captions de checkboxes definen los nombres

2. **Variable compartida**
   - Variable doctos es global en módulo padre
   - Persiste después de cerrar esta ventana
   - Módulo padre la usa para guardar en BD

3. **Sin separadores**
   - Documentos se concatenan directamente
   - No hay comas ni separadores entre ellos
   - El caption completo se agrega

4. **Procedimiento limpia**
   - Método limpia() reinicia todos los checkboxes
   - Limpia Edit1
   - Oculta Edit1
   - Deja interfaz en estado inicial

### Restricciones

1. **Checkboxes fijos**
   - No se pueden agregar más opciones sin modificar código
   - Limitado a los 19 documentos predefinidos + "Otros"

2. **Sin validación de mínimo**
   - Permite confirmar sin seleccionar nada
   - Responsabilidad del usuario marcar lo necesario

3. **Formato de salida**
   - No hay control sobre formato de la cadena generada
   - Es concatenación simple de captions

### Permisos necesarios
- Acceso al módulo de registro de trámites
- No requiere permisos especiales de BD

### Recomendaciones de uso

1. **Al seleccionar documentos**
   - Revisar lista completa antes de confirmar
   - Marcar solo documentos aplicables al trámite
   - Usar "Otros" para requisitos especiales
   - Documentos comunes típicos:
     - Identificación oficial
     - RFC
     - Comprobante de domicilio
     - Título de propiedad o contrato de arrendamiento
     - Planos
     - Uso de suelo
     - Licencia de construcción
     - Etc.

2. **Para documentos especiales**
   - Usar CheckBox21 y Edit1 para requisitos únicos
   - Ser específico en la descripción
   - Incluir detalles necesarios

3. **Antes de confirmar**
   - Revisar que todos los documentos necesarios estén marcados
   - Verificar texto en "Otros" si aplica
   - Confirmar que lista sea correcta

4. **Si se equivoca**
   - Puede volver a abrir el módulo
   - Las selecciones previas se pierden (limpia al abrir)
   - Debe volver a marcar todo

5. **Estandarización**
   - Usar mismos documentos para trámites similares
   - Mantener consistencia en requisitos
   - Revisar precedentes de trámites del mismo giro

### Documentos comunes por tipo de trámite

**Licencia Nueva:**
- Identificación oficial
- RFC
- Comprobante de domicilio propietario
- Título de propiedad o contrato arrendamiento
- Uso de suelo
- Licencia de construcción (si aplica)
- Planos arquitectónicos
- Dictamen de Protección Civil
- Póliza de seguro (casos específicos)

**Renovación:**
- Identificación oficial
- RFC
- Comprobante de domicilio
- Licencia anterior
- Comprobante de pago predial

**Cambio de Giro:**
- Identificación oficial
- Licencia actual
- Uso de suelo nuevo
- Dictamen de Protección Civil (si cambia riesgo)

**Traspaso:**
- Identificación oficial de ambas partes
- RFC del nuevo titular
- Licencia actual
- Contrato de compra-venta o cesión de derechos
- Comprobante de domicilio nuevo titular

### Procedimiento limpia()

Función auxiliar que:
```
limpia():
  - checkbox1.checked = false
  - checkbox2.checked = false
  ...
  - checkbox21.checked = false
  - edit1.text = ''
  - edit1.visible = false
```

Se puede llamar para reiniciar el formulario a estado inicial.
