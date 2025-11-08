<template>
  <div class="rpt-factura-emision-page">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Facturación de Estados de Cuenta</li>
      </ol>
    </nav>
    <h1>Facturación de Estados de Cuenta</h1>
    <form @submit.prevent="fetchFacturaEmision">
      <div class="form-row">
        <div class="form-group col-md-2">
          <label for="oficina">Oficina</label>
          <input type="number" v-model.number="form.oficina" class="form-control" id="oficina" required>
        </div>
        <div class="form-group col-md-2">
          <label for="axo">Año</label>
          <input type="number" v-model.number="form.axo" class="form-control" id="axo" required>
        </div>
        <div class="form-group col-md-2">
          <label for="periodo">Periodo</label>
          <input type="number" v-model.number="form.periodo" class="form-control" id="periodo" required>
        </div>
        <div class="form-group col-md-2">
          <label for="mercado">Mercado</label>
          <input type="number" v-model.number="form.mercado" class="form-control" id="mercado" required>
        </div>
        <div class="form-group col-md-2">
          <label for="opc">Opción</label>
          <select v-model.number="form.opc" class="form-control" id="opc" required>
            <option :value="1">Solo Mercado Seleccionado</option>
            <option :value="2">Todos los Mercados</option>
          </select>
        </div>
        <div class="form-group col-md-2 align-self-end">
          <button type="submit" class="btn btn-primary">Consultar</button>
        </div>
      </div>
    </form>
    <div v-if="loading" class="alert alert-info mt-3">Cargando...</div>
    <div v-if="error" class="alert alert-danger mt-3">{{ error }}</div>
    <div v-if="factura.length" class="table-responsive mt-4">
      <h3>Resultados de Facturación</h3>
      <table class="table table-bordered table-sm">
        <thead>
          <tr>
            <th>Datos Local</th>
            <th>Nombre</th>
            <th>Superficie</th>
            <th>Renta</th>
            <th>Importe</th>
            <th>Recaudadora</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in factura" :key="row.datoslocal">
            <td>{{ row.datoslocal }}</td>
            <td>{{ row.nombre }}</td>
            <td>{{ row.superficie }}</td>
            <td>{{ row.importe_cuota }}</td>
            <td>{{ row.importe }}</td>
            <td>{{ row.recaudadora }}</td>
          </tr>
        </tbody>
      </table>
      <div class="mt-3">
        <strong>Total Recibos:</strong> {{ factura.length }}<br>
        <strong>Total Superficie:</strong> {{ totalSuperficie }}<br>
        <strong>Total Importe:</strong> {{ totalImporte }}
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'RptFacturaEmisionPage',
  data() {
    return {
      form: {
        oficina: '',
        axo: '',
        periodo: '',
        mercado: '',
        opc: 1
      },
      factura: [],
      loading: false,
      error: ''
    }
  },
  computed: {
    totalSuperficie() {
      return this.factura.reduce((sum, row) => sum + Number(row.superficie || 0), 0).toFixed(2);
    },
    totalImporte() {
      return this.factura.reduce((sum, row) => sum + Number(row.importe || 0), 0).toFixed(2);
    }
  },
  methods: {
    async fetchFacturaEmision() {
      this.loading = true;
      this.error = '';
      this.factura = [];
      try {
        const response = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            action: 'getFacturaEmision',
            params: this.form
          })
        });
        const data = await response.json();
        if (data.status === 'success') {
          this.factura = data.data;
        } else {
          this.error = data.message || 'Error al consultar la facturación';
        }
      } catch (e) {
        this.error = e.message || 'Error de red';
      } finally {
        this.loading = false;
      }
    }
  }
}
</script>

<style scoped>
.rpt-factura-emision-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem;
}
.breadcrumb {
  background: #f8f9fa;
  margin-bottom: 1rem;
}
</style>
