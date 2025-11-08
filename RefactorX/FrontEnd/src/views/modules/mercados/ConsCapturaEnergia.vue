<template>
  <div class="cons-captura-energia">
    <div class="breadcrumb">
      <router-link to="/">Inicio</router-link> /
      <span>Consulta de Pagos Capturados de Energía Eléctrica</span>
    </div>
    <h1>Detalle de los Pagos Capturados</h1>
    <div class="actions">
      <button @click="fetchPagos">Actualizar</button>
    </div>
    <table class="pagos-table">
      <thead>
        <tr>
          <th>Control</th>
          <th>Datos del Local</th>
          <th>Año</th>
          <th>Mes</th>
          <th>Cuota</th>
          <th>Cantidad</th>
          <th>Fecha</th>
          <th>Rec</th>
          <th>Caja</th>
          <th>Oper</th>
          <th>Importe</th>
          <th>Folio</th>
          <th>Actualización</th>
          <th>Usuario</th>
          <th>Acciones</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="pago in pagos" :key="pago.id_pago_energia">
          <td>{{ pago.id_energia }}</td>
          <td>{{ pago.datoslocal }}</td>
          <td>{{ pago.axo }}</td>
          <td>{{ pago.periodo }}</td>
          <td>{{ pago.cve_consumo }}</td>
          <td>{{ pago.cantidad }}</td>
          <td>{{ pago.fecha_pago }}</td>
          <td>{{ pago.oficina_pago }}</td>
          <td>{{ pago.caja_pago }}</td>
          <td>{{ pago.operacion_pago }}</td>
          <td>{{ pago.importe_pago }}</td>
          <td>{{ pago.folio }}</td>
          <td>{{ pago.fecha_modificacion }}</td>
          <td>{{ pago.usuario }}</td>
          <td>
            <button @click="borrarPago(pago)">Borrar</button>
          </td>
        </tr>
      </tbody>
    </table>
    <div v-if="error" class="error">{{ error }}</div>
    <div class="footer">
      <button @click="$router.back()">Salir</button>
    </div>
  </div>
</template>

<script>
export default {
  name: 'ConsCapturaEnergia',
  data() {
    return {
      pagos: [],
      error: '',
      id_energia: null // Se puede obtener de la ruta o props
    };
  },
  created() {
    // Suponiendo que el id_energia viene por query o params
    this.id_energia = this.$route.query.id_energia || this.$route.params.id_energia;
    this.fetchPagos();
  },
  methods: {
    async fetchPagos() {
      this.error = '';
      try {
        const res = await this.$axios.post('/api/execute', {
          eRequest: {
            action: 'getPagosEnergia',
            params: { id_energia: this.id_energia }
          }
        });
        if (res.data.eResponse.success) {
          this.pagos = res.data.eResponse.data;
        } else {
          this.error = res.data.eResponse.message || 'Error al cargar pagos';
        }
      } catch (e) {
        this.error = e.message;
      }
    },
    async borrarPago(pago) {
      if (!confirm('¿Está seguro de borrar este pago?')) return;
      this.error = '';
      try {
        // Primero, intentar restaurar el adeudo si corresponde
        const restoreRes = await this.$axios.post('/api/execute', {
          eRequest: {
            action: 'restoreAdeudoEnergia',
            params: {
              id_energia: pago.id_energia,
              axo: pago.axo,
              periodo: pago.periodo,
              cve_consumo: pago.cve_consumo,
              cantidad: pago.cantidad,
              importe: pago.importe_pago,
              usuario_id: pago.id_usuario
            }
          }
        });
        // Luego, borrar el pago
        const res = await this.$axios.post('/api/execute', {
          eRequest: {
            action: 'deletePagoEnergia',
            params: {
              id_energia: pago.id_energia,
              axo: pago.axo,
              periodo: pago.periodo,
              usuario_id: pago.id_usuario
            }
          }
        });
        if (res.data.eResponse.success) {
          this.fetchPagos();
        } else {
          this.error = res.data.eResponse.message || 'Error al borrar pago';
        }
      } catch (e) {
        this.error = e.message;
      }
    }
  }
};
</script>

<style scoped>
.cons-captura-energia {
  padding: 24px;
}
.breadcrumb {
  margin-bottom: 12px;
  font-size: 14px;
}
.pagos-table {
  width: 100%;
  border-collapse: collapse;
  margin-bottom: 16px;
}
.pagos-table th, .pagos-table td {
  border: 1px solid #ccc;
  padding: 4px 8px;
  font-size: 13px;
}
.pagos-table th {
  background: #f0f0f0;
}
.actions {
  margin-bottom: 12px;
}
.footer {
  margin-top: 16px;
}
.error {
  color: red;
  margin-top: 12px;
}
</style>
