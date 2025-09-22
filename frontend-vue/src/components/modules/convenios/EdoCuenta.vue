<template>
  <div class="edo-cuenta-page">
    <h1>Emisión de Estado de Cuenta</h1>
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Estado de Cuenta</li>
      </ol>
    </nav>
    <form @submit.prevent="onSubmit">
      <div class="form-group">
        <label for="tipo">Tipo</label>
        <select v-model="form.tipo" id="tipo" class="form-control" required @change="onTipoChange">
          <option v-for="t in tipos" :key="t.value" :value="t.value">{{ t.label }}</option>
        </select>
      </div>
      <div class="form-group">
        <label for="subtipo">Subtipo</label>
        <select v-model="form.subtipo" id="subtipo" class="form-control" required>
          <option v-for="s in subtipos" :key="s.value" :value="s.value">{{ s.label }}</option>
        </select>
      </div>
      <div class="form-group">
        <button type="submit" class="btn btn-primary">Consultar Estado de Cuenta</button>
      </div>
    </form>
    <div v-if="loading" class="alert alert-info">Cargando...</div>
    <div v-if="error" class="alert alert-danger">{{ error }}</div>
    <div v-if="result && result.length">
      <h3>Resultados</h3>
      <table class="table table-bordered table-sm">
        <thead>
          <tr>
            <th>Manzana</th>
            <th>Lote</th>
            <th>Letra</th>
            <th>Nombre</th>
            <th>Calle</th>
            <th>Num. Ext.</th>
            <th>Num. Int.</th>
            <th>Inciso</th>
            <th>Cantidad Total</th>
            <th>Adeudo</th>
            <th>Total Pagado</th>
            <th>Total Recargos</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in result" :key="row.id_conv_resto">
            <td>{{ row.manzana }}</td>
            <td>{{ row.lote }}</td>
            <td>{{ row.letra }}</td>
            <td>{{ row.nombre }}</td>
            <td>{{ row.calle }}</td>
            <td>{{ row.num_exterior }}</td>
            <td>{{ row.num_interior }}</td>
            <td>{{ row.inciso }}</td>
            <td>{{ row.cantidad_total | currency }}</td>
            <td>{{ row.adeudo | currency }}</td>
            <td>{{ row.total_importe | currency }}</td>
            <td>{{ row.total_recargos | currency }}</td>
          </tr>
        </tbody>
      </table>
      <button class="btn btn-success" @click="onImprimir">Imprimir Estado de Cuenta</button>
    </div>
  </div>
</template>

<script>
export default {
  name: 'EdoCuentaPage',
  data() {
    return {
      tipos: [],
      subtipos: [],
      form: {
        tipo: '',
        subtipo: ''
      },
      result: null,
      loading: false,
      error: '',
    };
  },
  created() {
    this.fetchTipos();
  },
  methods: {
    async fetchTipos() {
      // Simulación: en producción, llamar a /api/execute con action: 'getTipos'
      this.tipos = [
        { value: '001', label: '001 - Regularización de Predios' },
        { value: '002', label: '002 - Otros' }
      ];
    },
    async onTipoChange() {
      // Simulación: en producción, llamar a /api/execute con action: 'getSubtipos'
      if (this.form.tipo === '001') {
        this.subtipos = [
          { value: '000001', label: '000001 - Subtipo 1' },
          { value: '000002', label: '000002 - Subtipo 2' }
        ];
      } else {
        this.subtipos = [
          { value: '000003', label: '000003 - Otro Subtipo' }
        ];
      }
      this.form.subtipo = '';
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
            eRequest: {
              action: 'list',
              tipo: this.form.tipo,
              subtipo: this.form.subtipo
            }
          })
        });
        const data = await res.json();
        if (data.eResponse && data.eResponse.success) {
          this.result = data.eResponse.data;
        } else {
          this.error = data.eResponse ? data.eResponse.message : 'Error desconocido';
        }
      } catch (e) {
        this.error = e.message;
      }
      this.loading = false;
    },
    onImprimir() {
      // Simulación: en producción, llamar a /api/execute con action: 'report'
      alert('Función de impresión no implementada en este demo.');
    }
  },
  filters: {
    currency(val) {
      if (typeof val !== 'number') return val;
      return '$' + val.toLocaleString('es-MX', { minimumFractionDigits: 2 });
    }
  }
};
</script>

<style scoped>
.edo-cuenta-page {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem;
}
.breadcrumb {
  background: #f8f9fa;
  padding: 0.5rem 1rem;
  margin-bottom: 1rem;
}
.table {
  margin-top: 1rem;
}
</style>
