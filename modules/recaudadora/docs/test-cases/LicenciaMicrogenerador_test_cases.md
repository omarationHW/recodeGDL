# Casos de Prueba: LicenciaMicrogenerador

## 1. Consulta de Licencia Vigente
- **Entrada:**
  - action: consulta
  - params: { tipo: 'L', licencia: 12345 }
- **Esperado:**
  - estatus: 1 o 2
  - mensaje: 'Ya existe como microgenerador' o 'No existe como microgenerador'
  - licencia: objeto con datos

## 2. Alta de Microgenerador
- **Entrada:**
  - action: alta
  - params: { tipo: 'L', id: 12345 }
- **Esperado:**
  - estatus: 1
  - mensaje: 'Alta exitosa, Licencia registrada como microgenerador'

## 3. Cancelación de Microgenerador
- **Entrada:**
  - action: cancelar
  - params: { tipo: 'L', id: 12345 }
- **Esperado:**
  - estatus: 1
  - mensaje: 'Cancelación exitosa, Licencia cancelada como microgenerador'

## 4. Consulta de Licencia Inexistente
- **Entrada:**
  - action: consulta
  - params: { tipo: 'L', licencia: 99999 }
- **Esperado:**
  - estatus: 0
  - mensaje: 'Licencia no vigente'

## 5. Alta de Microgenerador ya Existente
- **Entrada:**
  - action: alta
  - params: { tipo: 'L', id: 12345 }
- **Precondición:** Ya existe como microgenerador
- **Esperado:**
  - estatus: 0
  - mensaje: 'Ya existe como microgenerador'

## 6. Cancelación de Microgenerador Inexistente
- **Entrada:**
  - action: cancelar
  - params: { tipo: 'L', id: 99999 }
- **Esperado:**
  - estatus: 0
  - mensaje: 'No se encontró registro vigente para cancelar'
