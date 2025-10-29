<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="bolt" /></div>
      <div class="module-view-info">
        <h1>Emisión Recibos Energía</h1>
        <p>Mercados - Emisión Recibos Energía</p>
      </div>
    </div>

    <div class="module-view-content">
    <h2>Emisión de Recibos de Energía Eléctrica</h2>
    <form @submit.prevent="onSubmit" class="mb-4">
      <div class="row mb-2">
        <div class="col-md-3">
          <label>Oficina Recaudadora</label>
          <select v-model="form.oficina" class="municipal-form-control" required>
            <option v-for="of in oficinas" :key="of.id" :value="of.id">{{ of.nombre }}</option>
          </select>
        </div>
        <div class="col-md-3">
          <label>Mercado</label>
          <select v-model="form.mercado" class="municipal-form-control" required>
            <option v-for="m in mercados" :key="m.id" :value="m.id">{{ m.nombre }}</option>
          </select>
        </div>
        <div class="col-md-2">
          <label>Año</label>
          <input type="number" v-model="form.axo" class="municipal-form-control" required min="2000" max="2100">
        </div>
        <div class="col-md-2">
          <label>Periodo (Mes)</label>
          <select v-model="form.periodo" class="municipal-form-control" required>
            <option v-for="mes in meses" :key="mes.value" :value="mes.value">{{ mes.label }}</option>
          </select>
        </div>
        <div class="col-md-2 d-flex align-items-end">
          <button type="submit" class="btn-municipal-primary">Consultar</button>
        </div>
      </div>
    </form>
    <div v-if="loading" class="alert alert-info">Cargando datos...</div>
    <div v-if="error" class="alert alert-danger">{{ error }}</div>
    <div v-if="result && result.length">
      <h4>Recibos de Energía</h4>
      <table class="table table-bordered table-sm">
        <thead>
          <tr>
            <th>Datos Local</th>
            <th>Nombre</th>
            <th>Descripción</th>
            <th>Cuenta Energía</th>
            <th>Locales</th>
            <th>Kilowhatts</th>
            <th>Importe</th>
            <th>Tipo Consumo</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in result" :key="row.id_energia">
            <td>{{ row.datoslocal }}</td>
            <td>{{ row.nombre }}</td>
            <td>{{ row.descripcion }}</td>
            <td>{{ row.cuenta_energia }}</td>
            <td>{{ row.local_adicional }}</td>
            <td>{{ row.cantidad }}</td>
            <td>{{ row.importe_energia | currency }}</td>
            <td>{{ row.descripcion_consumo }}</td>
          </tr>
        </tbody>
      </table>
      <div class="mt-3">
        <button class="btn-municipal-success" @click="onPrint">Imprimir</button>
        <button class="btn btn-secondary ml-2" @click="onPreview">Previsualizar</button>
      </div>
    </div>
    <div v-else-if="result && !result.length">
      <div class="alert alert-warning">No se encontraron datos para los parámetros seleccionados.</div>
    </div>
  </div>
    <!-- /module-view-content -->
  </div>
  <!-- /module-view -->
</template>

<script>
export default {
  name: 'RptEmisionEnergiaPage',
  data() {
    return {
      form: {
        oficina: '',
        mercado: '',
        axo: new Date().getFullYear(),
        periodo: (new Date().getMonth() + 1)
      },
      oficinas: [],
      mercados: [],
      meses: [
        { value: 1, label: 'Enero' }, { value: 2, label: 'Febrero' }, { value: 3, label: 'Marzo' },
        { value: 4, label: 'Abril' }, { value: 5, label: 'Mayo' }, { value: 6, label: 'Junio' },
        { value: 7, label: 'Julio' }, { value: 8, label: 'Agosto' }, { value: 9, label: 'Septiembre' },
        { value: 10, label: 'Octubre' }, { value: 11, label: 'Noviembre' }, { value: 12, label: 'Diciembre' }
      ],
      result: null,
      loading: false,
      error: '',
    }
  },
  filters: {
    currency(val) {
      if (typeof val !== 'number') return val;
      return '$' + val.toLocaleString('es-MX', { minimumFractionDigits: 2 });
    }
  },
  created() {
    this.fetchOficinas();
  },
  watch: {
    'form.oficina'(val) {
      if (val) this.fetchMercados(val);
    }
  },
  methods: {
    fetchOficinas() {
      // Simulación: Reemplazar por llamada real a API
      this.oficinas = [
        { id: 1, nombre: 'Zona Centro' },
        { id: 2, nombre: 'Zona Olímpica' },
        { id: 3, nombre: 'Zona Oblatos' },
        { id: 4, nombre: 'Zona Minerva' },
        { id: 5, nombre: 'Cruz del Sur' }
      ];
    },
    fetchMercados(oficinaId) {
      // Simulación: Reemplazar por llamada real a API
      this.mercados = [
        { id: 1, nombre: 'Mercado de Abastos' },
        { id: 2, nombre: 'Mercado Libertad' },
        { id: 3, nombre: 'Mercado San Juan de Dios' }
      ];
    },
    async onSubmit() {
      this.loading = true;
      this.error = '';
      this.result = null;
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            action: 'getEmisionEnergia',
            params: this.form
          })
        });
        const data = await res.json();
        if (data.success) {
          this.result = data.data;
        } else {
          this.error = data.message || 'Error al consultar.';
        }
      } catch (e) {
        this.error = e.message;
      } finally {
        this.loading = false;
      }
    },
    async onPrint() {
      // Puede abrir PDF o trigger de impresión
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            action: 'printEmisionEnergia',
            params: this.form
          })
        });
        const data = await res.json();
        if (data.success && data.data && data.data.pdf_url) {
          window.open(data.data.pdf_url, '_blank');
        } else {
          alert('No se pudo generar el PDF.');
        }
      } catch (e) {
        alert('Error: ' + e.message);
      }
    },
    async onPreview() {
      // Puede mostrar preview en modal o similar
      alert('Funcionalidad de previsualización no implementada.');
    }
  }
}
</script>

<style scoped>
.rpt-emision-energia-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem;
}
</style>
