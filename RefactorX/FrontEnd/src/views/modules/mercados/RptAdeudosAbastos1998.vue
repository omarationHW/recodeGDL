<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="exclamation-triangle" /></div>
      <div class="module-view-info">
        <h1>Adeudos Abastos 1998</h1>
        <p>Mercados - Adeudos Abastos 1998</p>
      </div>
    </div>

    <div class="module-view-content">
    <h1>Listado de Adeudos de Mercados del Año: {{ axo }}</h1>
    <form @submit.prevent="fetchAdeudos">
      <div class="form-row">
        <div class="form-group col-md-2">
          <label class="municipal-form-label">Año</label>
          <input type="number" v-model="axo" class="municipal-form-control" min="1998" max="1998" />
        </div>
        <div class="form-group col-md-2">
          <label class="municipal-form-label">Oficina</label>
          <select v-model="oficina" class="municipal-form-control">
            <option v-for="of in oficinas" :key="of.value" :value="of.value">{{ of.label }}</option>
          </select>
        </div>
        <div class="form-group col-md-2">
          <label class="municipal-form-label">Periodo</label>
          <input type="number" v-model="periodo" class="municipal-form-control" min="1" max="12" />
        </div>
        <div class="form-group col-md-2 align-self-end">
          <button type="submit" class="btn-municipal-primary">Buscar</button>
        </div>
      </div>
    </form>
    <div v-if="loading" class="alert alert-info">Cargando datos...</div>
    <div v-if="error" class="alert alert-danger">{{ error }}</div>
    <div v-if="adeudos.length">
      <table class="-bordered municipal-table-sm mt-3">
        <thead>
          <tr>
            <th>Datos Local</th>
            <th>Nombre</th>
            <th>Superficie</th>
            <th>Adeudo</th>
            <th>Meses</th>
            <th>Tot. Meses</th>
            <th>Renta E/A</th>
            <th>Renta S/D</th>
            <th>Recaudadora</th>
            <th>Descripción</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in adeudos" :key="row.id_local">
            <td>{{ row.datoslocal }}</td>
            <td>{{ row.nombre }}</td>
            <td>{{ row.superficie }}</td>
            <td>{{ row.adeudo | currency }}</td>
            <td>{{ row.meses }}</td>
            <td>{{ row.totmeses }}</td>
            <td>{{ row.renta_ea | currency }}</td>
            <td>{{ row.renta_sd | currency }}</td>
            <td>{{ row.recaudadora }}</td>
            <td>{{ row.descripcion }}</td>
          </tr>
        </tbody>
      </table>
      <div class="mt-3">
        <strong>Total registros:</strong> {{ adeudos.length }}<br />
        <strong>Total adeudo:</strong> {{ totalAdeudo | currency }}
      </div>
    </div>
    <div v-else-if="!loading">No hay datos para los parámetros seleccionados.</div>
  </div>
    <!-- /module-view-content -->
  </div>
  <!-- /module-view -->
</template>

<script>
export default {
  name: 'AdeudosAbastos1998Page',
  data() {
    return {
      axo: 1998,
      oficina: 5,
      periodo: 12,
      oficinas: [
        { value: 1, label: 'Zona Centro' },
        { value: 2, label: 'Zona Olimpica' },
        { value: 3, label: 'Zona Oblatos' },
        { value: 4, label: 'Zona Minerva' },
        { value: 5, label: 'Cruz del Sur' }
      ],
      adeudos: [],
      loading: false,
      error: '',
    };
  },
  computed: {
    totalAdeudo() {
      return this.adeudos.reduce((sum, row) => sum + (parseFloat(row.adeudo) || 0), 0);
    }
  },
  methods: {
    async fetchAdeudos() {
      this.loading = true;
      this.error = '';
      this.adeudos = [];
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
          action: 'get_adeudos_abastos_1998',
          params: {
            axo: this.axo,
            oficina: this.oficina,
            periodo: this.periodo
          }
        });
        if (res.data.success) {
          this.adeudos = res.data.data;
        } else {
          this.error = res.data.message || 'Error al consultar los adeudos.';
        }
      } catch (e) {
        this.error = e.message || 'Error de red.';
      } finally {
        this.loading = false;
      }
    }
  },
  filters: {
    currency(val) {
      if (typeof val === 'number' || !isNaN(val)) {
        return '$' + parseFloat(val).toLocaleString('es-MX', { minimumFractionDigits: 2 });
      }
      return val;
    }
  },
  mounted() {
    this.fetchAdeudos();
  }
};
</script>

<style scoped>
.adeudos-abastos-1998-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem;
}
.breadcrumb {
  background: none;
  padding: 0;
  margin-bottom: 1rem;
}
</style>
