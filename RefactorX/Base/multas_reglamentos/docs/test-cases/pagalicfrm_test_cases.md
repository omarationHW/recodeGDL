# Casos de Prueba para Formulario pagalicfrm

| Caso | Descripción | Entrada | Resultado Esperado |
|------|-------------|---------|--------------------|
| TC01 | Buscar licencia existente con adeudos | tipo: licencia, numero: 1234, axo: 2024 | Se muestran los datos de la licencia y los adeudos pendientes |
| TC02 | Buscar licencia inexistente | tipo: licencia, numero: 999999, axo: 2024 | Mensaje de error: 'NO existe este numero de licencia' |
| TC03 | Buscar licencia sin adeudos | tipo: licencia, numero: 1234, axo: 2020 (sin adeudos) | Mensaje de error: 'NO existen adeudos para esta Licencia/Anuncio' |
| TC04 | Marcar licencia como pagada | tipo: licencia, numero: 1234, axo: 2024 | Mensaje de éxito: 'Licencia marcada como pagada correctamente.' y los adeudos desaparecen |
| TC05 | Buscar anuncio existente con adeudos | tipo: anuncio, numero: 5678, axo: 2024 | Se muestran los datos del anuncio y los adeudos pendientes |
| TC06 | Marcar anuncio como pagado | tipo: anuncio, numero: 5678, axo: 2024 | Mensaje de éxito: 'Anuncio marcado como pagado correctamente.' y los adeudos desaparecen |
| TC07 | Buscar anuncio inexistente | tipo: anuncio, numero: 888888, axo: 2024 | Mensaje de error: 'NO existe este numero de anuncio' |
| TC08 | Buscar anuncio sin adeudos | tipo: anuncio, numero: 5678, axo: 2020 (sin adeudos) | Mensaje de error: 'NO existen adeudos para esta Licencia/Anuncio' |
