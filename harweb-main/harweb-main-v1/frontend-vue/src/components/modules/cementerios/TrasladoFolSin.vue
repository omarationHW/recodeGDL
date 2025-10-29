<template>
  <div class="traslado-fol-sin-page">
    <h1>Traslado de Pagos de Cementerio Sin Afectar Adeudos</h1>
    <div class="form-section">
      <h2>Buscar Folios</h2>
      <form @submit.prevent="verificaFolios">
        <div class="form-group">
          <label for="folioDe">Folio DE TRASLADO</label>
          <input v-model="folioDe" id="folioDe" type="number" min="1" required />
        </div>
        <div class="form-group">
          <label for="folioA">Folio A TRASLADAR</label>
          <input v-model="folioA" id="folioA" type="number" min="1" required />
        </div>
        <button type="submit">Verificar</button>
      </form>
      <div v-if="errorMessage" class="error">{{ errorMessage }}</div>
    </div>

    <div v-if="foliosValid" class="folios-section">
      <h2>Datos de Folio DE TRASLADO</h2>
      <table class="folio-table">
        <tr><th>Cementerio</th><td>{{ datosDe.cementerio }}</td></tr>
        <tr><th>Clase</th><td>{{ datosDe.clase }} {{ datosDe.clase_alfa }}</td></tr>
        <tr><th>Sección</th><td>{{ datosDe.seccion }} {{ datosDe.seccion_alfa }}</td></tr>
        <tr><th>Línea</th><td>{{ datosDe.linea }} {{ datosDe.linea_alfa }}</td></tr>
        <tr><th>Fosa</th><td>{{ datosDe.fosa }} {{ datosDe.fosa_alfa }}</td></tr>
        <tr><th>Nombre</th><td>{{ datosDe.nombre }}</td></tr>
      </table>
      <h3>Pagos a trasladar</h3>
      <table class="pagos-table">
        <thead>
          <tr>
            <th></th>
            <th>Fecha Ingreso</th>
            <th>Rec</th>
            <th>Caja</th>
            <th>Importe</th>
            <th>Año Desde</th>
            <th>Año Hasta</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="pago in pagosDe" :key="pago.control_id">
            <td><input type="checkbox" v-model="pagosSeleccionados" :value="pago.control_id" /></td>
            <td>{{ pago.fecing }}</td>
            <td>{{ pago.recing }}</td>
            <td>{{ pago.cajing }}</td>
            <td>{{ pago.importe_anual }}</td>
            <td>{{ pago.axo_pago_desde }}</td>
            <td>{{ pago.axo_pago_hasta }}</td>
          </tr>
        </tbody>
      </table>
      <h2>Datos de Folio A TRASLADAR</h2>
      <table class="folio-table">
        <tr><th>Cementerio</th><td>{{ datosA.cementerio }}</td></tr>
        <tr><th>Clase</th><td>{{ datosA.clase }} {{ datosA.clase_alfa }}</td></tr>
        <tr><th>Sección</th><td>{{ datosA.seccion }} {{ datosA.seccion_alfa }}</td></tr>
        <tr><th>Línea</th><td>{{ datosA.linea }} {{ datosA.linea_alfa }}</td></tr>
        <tr><th>Fosa</th><td>{{ datosA.fosa }} {{ datosA.fosa_alfa }}</td></tr>
        <tr><th>Nombre</th><td>{{ datosA.nombre }}</td></tr>
      </table>
      <button @click="trasladarPagos" :disabled="pagosSeleccionados.length === 0">Trasladar Pagos Seleccionados</button>
      <div v-if="successMessage" class="success">{{ successMessage }}</div>
      <div v-if="errorMessage2" class="error">{{ errorMessage2 }}</div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'TrasladoFolSinPage',
  data() {
    return {
      folioDe: '',
      folioA: '',
      errorMessage: '',
      errorMessage2: '',
      successMessage: '',
      foliosValid: false,
      datosDe: {},
      datosA: {},
      pagosDe: [],
      pagosA: [],
      pagosSeleccionados: [],
      usuarioId: 1 // Debe obtenerse del contexto de sesión real
    };
  },
  methods: {
    async verificaFolios() {
      this.errorMessage = '';
      this.successMessage = '';
      this.foliosValid = false;
      this.pagosSeleccionados = [];
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'cementerios.verificaFolios',
          payload: {
            folio_de: this.folioDe,
            folio_a: this.folioA
          }
        });
        if (res.data.status === 'success') {
          this.datosDe = res.data.data.datos_de;
          this.datosA = res.data.data.datos_a;
          this.pagosDe = res.data.data.pagos_de;
          this.pagosA = res.data.data.pagos_a;
          this.foliosValid = true;
        } else {
          throw new Error(res.data.message || 'Error en la solicitud');
        }
      } catch (error) {
        this.errorMessage = error.response?.data?.message || error.message || 'Error de conexión';
      }
    },
    async trasladarPagos() {
      this.errorMessage2 = '';
      this.successMessage = '';
      if (this.pagosSeleccionados.length === 0) {
        this.errorMessage2 = 'Debe seleccionar al menos un pago.';
        return;
      }
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'cementerios.trasladarPagos',
          payload: {
            folio_de: this.folioDe,
            folio_a: this.folioA,
            pagos_ids: this.pagosSeleccionados,
            usuario_id: this.usuarioId
          }
        });
        if (res.data.status === 'success') {
          this.successMessage = res.data.message;
          // Refrescar pagosDe
          await this.verificaFolios();
        } else {
          throw new Error(res.data.message || 'Error en la solicitud');
        }
      } catch (error) {
        this.errorMessage2 = error.response?.data?.message || error.message || 'Error de conexión';
      }
    }
  }
};
</script>

<style scoped>
.traslado-fol-sin-page {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem;
}
.form-section, .folios-section {
  margin-bottom: 2rem;
  background: #f9f9f9;
  padding: 1rem 2rem;
  border-radius: 8px;
}
.form-group {
  margin-bottom: 1rem;
}
.folio-table, .pagos-table {
  width: 100%;
  border-collapse: collapse;
  margin-bottom: 1rem;
}
.folio-table th, .folio-table td, .pagos-table th, .pagos-table td {
  border: 1px solid #ddd;
  padding: 0.5rem;
}
.error {
  color: #b00;
  margin-top: 1rem;
}
.success {
  color: #080;
  margin-top: 1rem;
}
button {
  padding: 0.5rem 1.5rem;
  background: #007bff;
  color: #fff;
  border: none;
  border-radius: 4px;
  cursor: pointer;
}
button:disabled {
  background: #aaa;
  cursor: not-allowed;
}
</style>
