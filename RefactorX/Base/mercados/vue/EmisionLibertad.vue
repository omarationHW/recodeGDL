<template>
  <div class="emision-libertad-page">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Emisión Libertad</li>
      </ol>
    </nav>
    <h2>Emisión de Recibos para Mercados con Caja de Cobro</h2>
    <form @submit.prevent="generarEmision">
      <div class="form-row">
        <div class="form-group col-md-2">
          <label for="axo">Año</label>
          <input type="number" v-model="form.axo" min="2003" max="2999" class="form-control" required />
        </div>
        <div class="form-group col-md-2">
          <label for="periodo">Periodo (Mes)</label>
          <input type="number" v-model="form.periodo" min="1" max="12" class="form-control" required />
        </div>
        <div class="form-group col-md-3">
          <label for="recaudadora">Recaudadora</label>
          <select v-model="form.oficina" class="form-control" @change="fetchMercados" required>
            <option v-for="rec in recaudadoras" :key="rec.id_rec" :value="rec.id_rec">{{ rec.id_rec }} - {{ rec.recaudadora }}</option>
          </select>
        </div>
      </div>
      <div class="form-group">
        <label>Mercados</label>
        <div class="mercados-list">
          <div v-for="merc in mercados" :key="merc.num_mercado_nvo">
            <input type="checkbox" :id="'mercado-' + merc.num_mercado_nvo" :value="merc.num_mercado_nvo" v-model="form.mercados" />
            <label :for="'mercado-' + merc.num_mercado_nvo">{{ merc.num_mercado_nvo }} - {{ merc.descripcion }}</label>
          </div>
        </div>
      </div>
      <div class="form-group mt-3">
        <button type="submit" class="btn btn-primary" :disabled="loading">Generar Emisión</button>
        <button type="button" class="btn btn-success ml-2" @click="exportarEmision" :disabled="!emision.length || loading">Exportar TXT</button>
      </div>
    </form>
    <div v-if="loading" class="mt-3 alert alert-info">Procesando...</div>
    <div v-if="error" class="mt-3 alert alert-danger">{{ error }}</div>
    <div v-if="emision.length" class="mt-4">
      <h4>Detalle de Emisión</h4>
      <table class="table table-sm table-bordered">
        <thead>
          <tr>
            <th>Local</th>
            <th>Nombre</th>
            <th>Mercado</th>
            <th>Renta</th>
            <th>Descuento</th>
            <th>Adeudos</th>
            <th>Recargos</th>
            <th>Subtotal</th>
            <th>Multas</th>
            <th>Gastos</th>
            <th>Folios Req.</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in emision" :key="row.id_local">
            <td>{{ row.id_local }}</td>
            <td>{{ row.nombre }}</td>
            <td>{{ row.descripcion }}</td>
            <td>{{ row.renta | money }}</td>
            <td>{{ row.descuento | money }}</td>
            <td>{{ row.adeudos | money }}</td>
            <td>{{ row.recargos | money }}</td>
            <td>{{ row.subtotal | money }}</td>
            <td>{{ row.multas | money }}</td>
            <td>{{ row.gastos | money }}</td>
            <td>{{ row.folios }}</td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<script>
export default {
  name: 'EmisionLibertadPage',
  data() {
    return {
      recaudadoras: [],
      mercados: [],
      emision: [],
      loading: false,
      error: '',
      form: {
        axo: new Date().getFullYear(),
        periodo: new Date().getMonth() + 1,
        oficina: '',
        mercados: [],
        usuario_id: 1 // Simulación, debe venir del login
      }
    }
  },
  filters: {
    money(val) {
      if (val == null) return '';
      return '$' + parseFloat(val).toFixed(2);
    }
  },
  created() {
    this.fetchRecaudadoras();
  },
  methods: {
    async fetchRecaudadoras() {
      this.loading = true;
      this.error = '';
      try {
        const res = await this.$axios.post('/api/execute', { action: 'getRecaudadoras' });
        this.recaudadoras = res.data.data;
      } catch (e) {
        this.error = 'Error cargando recaudadoras';
      } finally {
        this.loading = false;
      }
    },
    async fetchMercados() {
      if (!this.form.oficina) return;
      this.loading = true;
      this.error = '';
      try {
        const res = await this.$axios.post('/api/execute', { action: 'getMercadosByRecaudadora', params: { oficina: this.form.oficina } });
        this.mercados = res.data.data;
      } catch (e) {
        this.error = 'Error cargando mercados';
      } finally {
        this.loading = false;
      }
    },
    async generarEmision() {
      this.loading = true;
      this.error = '';
      this.emision = [];
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'generarEmisionLibertad',
          params: {
            oficina: this.form.oficina,
            mercados: this.form.mercados,
            axo: this.form.axo,
            periodo: this.form.periodo,
            usuario_id: this.form.usuario_id
          }
        });
        if (res.data.success) {
          this.emision = res.data.data;
        } else {
          this.error = res.data.message || 'Error generando emisión';
        }
      } catch (e) {
        this.error = 'Error generando emisión';
      } finally {
        this.loading = false;
      }
    },
    async exportarEmision() {
      this.loading = true;
      this.error = '';
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'exportarEmisionLibertad',
          params: {
            oficina: this.form.oficina,
            mercados: this.form.mercados,
            axo: this.form.axo,
            periodo: this.form.periodo,
            usuario_id: this.form.usuario_id
          }
        });
        if (res.data.success && res.data.data && res.data.data.file_url) {
          window.open(res.data.data.file_url, '_blank');
        } else {
          this.error = res.data.message || 'No se pudo exportar el archivo';
        }
      } catch (e) {
        this.error = 'Error exportando archivo';
      } finally {
        this.loading = false;
      }
    }
  }
}
</script>

<style scoped>
.emision-libertad-page {
  max-width: 1100px;
  margin: 0 auto;
  padding: 2rem;
}
.mercados-list {
  max-height: 200px;
  overflow-y: auto;
  border: 1px solid #eee;
  padding: 0.5rem;
  background: #fafafa;
}
</style>
