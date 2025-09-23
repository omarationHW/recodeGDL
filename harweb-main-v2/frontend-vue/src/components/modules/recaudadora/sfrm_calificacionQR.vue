<template>
  <div class="calificacion-qr-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Calificación QR</li>
      </ol>
    </nav>
    <h1>Impresión de Calificación QR</h1>
    <form @submit.prevent="buscarMulta">
      <div class="form-group row">
        <label for="id_multa" class="col-sm-2 col-form-label">ID Multa</label>
        <div class="col-sm-4">
          <input type="number" v-model.number="id_multa" class="form-control" id="id_multa" required />
        </div>
        <div class="col-sm-2">
          <button type="submit" class="btn btn-primary">Buscar</button>
        </div>
      </div>
    </form>
    <div v-if="loading" class="alert alert-info mt-3">Cargando...</div>
    <div v-if="error" class="alert alert-danger mt-3">{{ error }}</div>
    <div v-if="calificacion" class="card mt-4">
      <div class="card-header">Datos de la Multa</div>
      <div class="card-body">
        <div class="row">
          <div class="col-md-6">
            <p><strong>ID Multa:</strong> {{ calificacion.id_multa }}</p>
            <p><strong>Dependencia:</strong> {{ calificacion.id_dependencia }}</p>
            <p><strong>Año Acta:</strong> {{ calificacion.axo_acta }}</p>
            <p><strong>Número Acta:</strong> {{ calificacion.num_acta }}</p>
            <p><strong>Fecha Acta:</strong> {{ formatDate(calificacion.fecha_acta) }}</p>
            <p><strong>Contribuyente:</strong> {{ calificacion.contribuyente }}</p>
            <p><strong>Domicilio:</strong> {{ calificacion.domicilio }}</p>
            <p><strong>Recaud:</strong> {{ calificacion.recaud }}</p>
            <p><strong>Número Licencia:</strong> {{ calificacion.num_licencia }}</p>
            <p><strong>Giro:</strong> {{ calificacion.giro }}</p>
          </div>
          <div class="col-md-6">
            <p><strong>Calificación:</strong> {{ calificacion.calificacion }}</p>
            <p><strong>Multa:</strong> {{ calificacion.multa }}</p>
            <p><strong>Gastos:</strong> {{ calificacion.gastos }}</p>
            <p><strong>Total:</strong> {{ calificacion.total }}</p>
            <p><strong>Clave Pago:</strong> {{ calificacion.cvepago }}</p>
            <p><strong>Capturista:</strong> {{ calificacion.capturista }}</p>
            <p><strong>Fecha Cancelación:</strong> {{ formatDate(calificacion.fecha_cancelacion) }}</p>
            <div class="mt-3">
              <qrcode-vue :value="qrValue" :size="128" />
            </div>
          </div>
        </div>
        <div class="mt-4">
          <h5>Artículos Relacionados</h5>
          <table class="table table-sm table-bordered">
            <thead>
              <tr>
                <th>Artículo</th>
                <th>Fracción</th>
                <th>Inciso</th>
                <th>Artículo Ley</th>
                <th>Fracción Ley</th>
                <th>Inciso Ley</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="art in articulos" :key="art.id_ley">
                <td>{{ art.art_reg }}</td>
                <td>{{ art.fracc_reg }}</td>
                <td>{{ art.inciso_reg }}</td>
                <td>{{ art.art_ley }}</td>
                <td>{{ art.fracc_ley }}</td>
                <td>{{ art.inciso_ley }}</td>
              </tr>
            </tbody>
          </table>
        </div>
        <div class="mt-4">
          <button class="btn btn-success" @click="imprimir">Imprimir</button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import QrcodeVue from 'qrcode.vue';
export default {
  name: 'CalificacionQRPage',
  components: { QrcodeVue },
  data() {
    return {
      id_multa: '',
      calificacion: null,
      articulos: [],
      loading: false,
      error: null
    };
  },
  computed: {
    qrValue() {
      if (!this.calificacion) return '';
      // Simula el string QR del Delphi: dependencia|año|num_acta|fecha_acta|contribuyente
      return [
        this.calificacion.id_dependencia,
        this.calificacion.axo_acta,
        this.calificacion.num_acta,
        this.formatDate(this.calificacion.fecha_acta),
        this.calificacion.contribuyente
      ].join('|');
    }
  },
  methods: {
    async buscarMulta() {
      this.loading = true;
      this.error = null;
      this.calificacion = null;
      this.articulos = [];
      try {
        const response = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: 'get_calificacion_qr_full',
            params: { id_multa: this.id_multa }
          })
        });
        const json = await response.json();
        if (json.eResponse.success && json.eResponse.data && json.eResponse.data.calificacion) {
          this.calificacion = json.eResponse.data.calificacion;
          this.articulos = json.eResponse.data.articulos;
        } else {
          this.error = 'No hay multa con este dato';
        }
      } catch (err) {
        this.error = err.message || 'Error de comunicación con el servidor';
      } finally {
        this.loading = false;
      }
    },
    formatDate(dateStr) {
      if (!dateStr) return '';
      const d = new Date(dateStr);
      if (isNaN(d)) return dateStr;
      return d.toLocaleDateString();
    },
    imprimir() {
      window.print();
    }
  }
};
</script>

<style scoped>
.calificacion-qr-page {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem 1rem;
}
.card {
  margin-top: 1rem;
}
@media print {
  nav, form, .btn, .breadcrumb {
    display: none !important;
  }
  .card {
    box-shadow: none;
    border: none;
  }
}
</style>
