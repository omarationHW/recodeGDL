## Casos de Prueba SGCv2

### Caso 1: Alta de Trámite de Licencia
- **Entrada:**
  - action: altaTramiteLicencia
  - params: { tipo_tramite: 1, id_giro: 123, propietario: "Juan Perez", rfc: "PEJJ800101XXX", ... }
- **Esperado:**
  - eResponse: { id_tramite: <int>, status: "ok" }

### Caso 2: Bloqueo de Licencia
- **Entrada:**
  - action: bloquearLicencia
  - params: { licencia: 456, motivo: "Falta de pago", usuario: "admin" }
- **Esperado:**
  - eResponse: { licencia: 456, status: "bloqueada" }

### Caso 3: Consulta de Licencia
- **Entrada:**
  - action: consultaLicencia
  - params: { licencia: 456 }
- **Esperado:**
  - eResponse: { ...datos de la licencia... }

### Caso 4: Baja de Licencia
- **Entrada:**
  - action: bajaLicencia
  - params: { licencia: 456, motivo: "Cierre definitivo", usuario: "admin" }
- **Esperado:**
  - eResponse: { licencia: 456, status: "baja" }

### Caso 5: Consulta de Trámite
- **Entrada:**
  - action: consultaTramite
  - params: { tramite: 789 }
- **Esperado:**
  - eResponse: { ...datos del trámite... }
