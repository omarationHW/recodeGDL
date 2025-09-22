## Casos de Prueba para EnergiaMtto

### Caso 1: Alta exitosa de energía
- **Entrada:** Local válido sin energía, datos completos y correctos.
- **Acción:** Enviar eRequest con action 'alta_energia_mtto' y datos válidos.
- **Esperado:** eResponse.success = true, data contiene 'OK', mensaje vacío.

### Caso 2: Alta en local con energía existente
- **Entrada:** Local con energía ya registrada.
- **Acción:** Enviar eRequest con action 'buscar_local' y datos del local.
- **Esperado:** eResponse.success = true, data vacío o error, mensaje indica que ya existe energía.

### Caso 3: Vigencia inválida
- **Entrada:** Alta de energía con vigencia distinta de 'A' o 'E'.
- **Acción:** Enviar eRequest con action 'alta_energia_mtto' y vigencia 'X'.
- **Esperado:** eResponse.success = false, mensaje de error sobre vigencia.

### Caso 4: Cantidad cero o vacía
- **Entrada:** Alta de energía con cantidad = 0 o vacío.
- **Acción:** Enviar eRequest con action 'alta_energia_mtto' y cantidad 0.
- **Esperado:** eResponse.success = false, mensaje de error sobre cantidad.

### Caso 5: Usuario sin permisos
- **Entrada:** Usuario autenticado sin permisos sobre la recaudadora.
- **Acción:** Enviar eRequest con action 'alta_energia_mtto' y user_id de otro recaudador.
- **Esperado:** eResponse.success = false, mensaje de error de permisos.
