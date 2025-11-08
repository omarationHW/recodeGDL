# Adquira32 - Sistema de Estacionamientos

## Proposito Administrativo

Procesar pagos con tarjeta de credito/debito a traves de terminal punto de venta (PinPad) para el cobro de folios de estacionamiento. Integra el sistema municipal con el servicio de adquirencia bancaria.

## Funcionalidad Principal

Biblioteca de funciones para leer datos de tarjetas bancarias mediante dispositivo PinPad (Nurit), encriptar informacion sensible y enviar transacciones de pago al servidor adquirente para autorizacion.

## Proceso de Negocio

### Que hace
- Lee datos de tarjetas (numero, vencimiento, nombre) desde PinPad Nurit
- Encripta informacion sensible (numero de tarjeta, CVV2) con algoritmos Rijndael y HMAC
- Construye mensajes XML con datos de transaccion
- Envia transacciones al servidor adquirente
- Recibe y decodifica respuestas de autorizacion/rechazo

### Para que
- Permitir que ciudadanos paguen folios de estacionamiento con tarjeta bancaria
- Eliminar riesgo de manejo de efectivo
- Agilizar cobros en ventanilla
- Generar comprobantes electronicos automaticos
- Dar mas opciones de pago a contribuyentes

### Como funciona
1. Cajero selecciona opcion pago con tarjeta
2. Sistema solicita deslizar/insertar tarjeta en PinPad
3. PinPad lee datos de tarjeta (banda magnetica o chip)
4. Sistema encripta numero de tarjeta y datos sensibles
5. Construye XML con: referencia, importe, datos encriptados
6. Envia al servidor adquirente via web service
7. Recibe respuesta: autorizacion (con folio) o rechazo (con motivo)
8. Aplica pago si autorizado o cancela si rechazado

### Que necesita
- Dispositivo PinPad Nurit conectado y operativo
- Libreria Nurit293v1_TLB instalada
- Conexion a internet activa
- Servidor adquirente disponible
- Contrato con banco adquirente vigente
- Claves de encriptacion configuradas

## Datos y Tablas

### No accede directamente a tablas
Este modulo es una libreria de funciones, no consulta base de datos. Los datos se pasan como parametros.

### Estructuras de datos
- **rcTarjeta**: nombre titular, numero tarjeta, mes/anio vencimiento, chip (si/no), track2
- **rcEnviado**: datos de transaccion a enviar (id transaccion, referencia, importe, tipo servicio, datos tarjeta encriptados)
- **rcRecibido**: respuesta del banco (autorizacion, folio pago, resultado, mensajes error)

### Datos clave procesados
- Numero de tarjeta (encriptado)
- Fecha vencimiento (MM/YY)
- Importe a cobrar
- Referencia del folio municipal
- Codigo autorizacion bancaria
- Folio de pago

## Impacto y Repercusiones

### Impacto operativo
- ALTO: Fallas impiden cobrar con tarjeta, obligando pago en efectivo
- Incrementa recaudacion al facilitar pagos
- Reduce tiempo de atencion en ventanilla

### Repercusiones
- Error en encriptacion puede exponer datos de tarjetas (CRITICO seguridad)
- Fallas de comunicacion generan transacciones pendientes
- Desconexion de PinPad obliga a reiniciar cobro
- Problemas con banco adquirente paralizan cobros con tarjeta

## Validaciones

1. Tarjeta leida correctamente: numero valido, vencimiento presente
2. Datos numericos: validacion de formato de montos
3. Track2 presente: verifica lectura completa
4. XML bien formado: estructura correcta para envio
5. Respuesta del banco: valida que se recibio respuesta

## Casos de Uso

### Caso 1: Pago exitoso con tarjeta
1. Ciudadano debe pagar folio de $500
2. Cajero selecciona pago con tarjeta
3. Sistema solicita deslizar tarjeta
4. Ciudadano desliza tarjeta Visa en PinPad
5. Sistema lee datos, encripta y envia
6. Banco autoriza transaccion (cod. 12345)
7. Sistema aplica pago al folio
8. Imprime comprobante con codigo autorizacion

### Caso 2: Tarjeta rechazada
1. Ciudadano intenta pagar folio
2. Desliza tarjeta en PinPad
3. Sistema envia transaccion
4. Banco rechaza (fondos insuficientes)
5. Sistema muestra mensaje de rechazo
6. Cajero solicita forma de pago alterna

### Caso 3: Error de lectura
1. Ciudadano desliza tarjeta rapidamente
2. PinPad no lee correctamente
3. Sistema detecta lectura incompleta
4. Solicita volver a deslizar tarjeta
5. Segunda lectura es exitosa y procede

## Usuarios del Modulo

- Cajeros: operan PinPad para cobrar folios
- Supervisores: autorizan transacciones especiales
- Administradores: configuran parametros de conexion bancaria
- Personal tecnico: da mantenimiento a PinPad

## Relaciones con Otros Modulos

- Nurit_TLB: componente COM que controla el dispositivo PinPad
- Modulos de cobro: llaman funciones de esta libreria para procesar pagos
- Sistema bancario: servidor remoto que autoriza transacciones
- Tablas de pagos: otros modulos registran pagos autorizados

## Notas Importantes

- Usa encriptacion Rijndael (AES) para numero de tarjeta
- HMAC para integridad y autenticacion de mensajes
- Formato XML estandar para intercambio con banco
- NO almacena nunca numeros de tarjeta completos (PCI compliance)
- Track2 contiene datos encriptados de banda magnetica
- Tipo servicio 9: indica pago de multas/infracciones
- Moneda 0: pesos mexicanos
- Requiere certificados digitales para conexion segura
