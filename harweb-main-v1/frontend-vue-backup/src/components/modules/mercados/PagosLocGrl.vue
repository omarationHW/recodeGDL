<template>
  <div class="pagos-loc-grl-page">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Pagos por Mercado</li>
      </ol>
    </nav>
    <h2>Reporte de Pagos por Mercado</h2>
    <div class="card mb-3">
      <div class="card-body">
        <form @submit.prevent="buscarPagos">
          <div class="row">
            <div class="col-md-3">
              <label>Oficina Recaudadora</label>
              <select v-model="form.recaudadora_id" class="form-control" @change="onRecaudadoraChange">
                <option value="">Seleccione...</option>
                <option v-for="rec in recaudadoras" :key="rec.id_rec" :value="rec.id_rec">{{ rec.id_rec }} - {{ rec.recaudadora }}</option>
              </select>
            </div>
            <div class="col-md-5">
              <label>Mercado</label>
              <select v-model="form.mercado_id" class="form-control">
                <option value="">Seleccione...</option>
                <option v-for="merc in mercados" :key="merc.num_mercado_nvo" :value="merc.num_mercado_nvo">{{ merc.num_mercado_nvo }} - {{ merc.descripcion }}</option>
              </select>
            </div>
            <div class="col-md-2">
              <label>Desde</label>
              <input type="date" v-model="form.fecha_desde" class="form-control" />
            </div>
            <div class="col-md-2">
              <label>Hasta</label>
              <input type="date" v-model="form.fecha_hasta" class="form-control" />
            </div>
          </div>
          <div class="mt-3">
            <button type="submit" class="btn btn-primary">Buscar</button>
            <button type="button" class="btn btn-success ml-2" @click="exportarExcel" :disabled="pagos.length === 0">Exportar a Excel</button>
          </div>
        </form>
      </div>
    </div>
    <div v-if="loading" class="alert alert-info">Cargando datos...</div>
    <div v-if="error" class="alert alert-danger">{{ error }}</div>
    <div v-if="pagos.length > 0">
      <h5>Resultados</h5>
      <div class="table-responsive">
        <table class="table table-sm table-bordered table-hover">
          <thead class="thead-light">
            <tr>
              <th>Mercado</th>
              <th>Sección</th>
              <th>Local</th>
              <th>Letra</th>
              <th>Bloque</th>
              <th>Año Pago</th>
              <th>Mes Pago</th>
              <th>Fecha Pago</th>
              <th>Rec.</th>
              <th>Caja</th>
              <th>Operación</th>
              <th>Renta Pagada</th>
              <th>Recibo</th>
              <th>Fecha Movimiento</th>
              <th>Usuario</th>
              <th>Fecha Req.</th>
              <th>Folio Req.</th>
              <th>Periodos Requeridos</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="row in pagos" :key="row.id_local + '-' + row.axo + '-' + row.periodo + '-' + row.operacion_pago">
              <td>{{ row.num_mercado }}</td>
              <td>{{ row.seccion }}</td>
              <td>{{ row.local }}</td>
              <td>{{ row.letra_local }}</td>
              <td>{{ row.bloque }}</td>
              <td>{{ row.axo }}</td>
              <td>{{ row.periodo }}</td>
              <td>{{ row.fecha_pago }}</td>
              <td>{{ row.oficina_pago }}</td>
              <td>{{ row.caja_pago }}</td>
              <td>{{ row.operacion_pago }}</td>
              <td>{{ row.importe_pago }}</td>
              <td>{{ row.folio }}</td>
              <td>{{ row.fecha_modificacion }}</td>
              <td>{{ row.usuario }}</td>
              <td>{{ row.fecha_emision }}</td>
              <td>{{ row.folio_1 }}</td>
              <td>{{ row.requerimientos }}</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'PagosLocGrlPage',
  data() {
    return {
      recaudadoras: [],
      mercados: [],
      pagos: [],
      loading: false,
      error: '',
      form: {
        recaudadora_id: '',
        mercado_id: '',
        fecha_desde: '',
        fecha_hasta: ''
      }
    };
  },
  created() {
    this.fetchRecaudadoras();
  },
  methods: {
    async fetchRecaudadoras() {
      this.loading = true;
      this.error = '';
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'getRecaudadoras',
          params: {}
        });
        if (res.data.success) {
          this.recaudadoras = res.data.data;
        } else {
          this.error = res.data.message || 'Error al cargar recaudadoras';
        }
      } catch (e) {
        this.error = e.message;
      } finally {
        this.loading = false;
      }
    },
    async onRecaudadoraChange() {
      this.form.mercado_id = '';
      this.mercados = [];
      if (!this.form.recaudadora_id) return;
      this.loading = true;
      this.error = '';
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'getMercadosByRecaudadora',
          params: { recaudadora_id: this.form.recaudadora_id }
        });
        if (res.data.success) {
          this.mercados = res.data.data;
        } else {
          this.error = res.data.message || 'Error al cargar mercados';
        }
      } catch (e) {
        this.error = e.message;
      } finally {
        this.loading = false;
      }
    },
    async buscarPagos() {
      this.loading = true;
      this.error = '';
      this.pagos = [];
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'getPagosLocGrl',
          params: {
            recaudadora_id: this.form.recaudadora_id,
            mercado_id: this.form.mercado_id,
            fecha_desde: this.form.fecha_desde,
            fecha_hasta: this.form.fecha_hasta
          }
        });
        if (res.data.success) {
          this.pagos = res.data.data;
        } else {
          this.error = res.data.message || 'Error al buscar pagos';
        }
      } catch (e) {
        this.error = e.message;
      } finally {
        this.loading = false;
      }
    },
    async exportarExcel() {
      this.loading = true;
      this.error = '';
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'exportPagosLocGrlExcel',
          params: {
            recaudadora_id: this.form.recaudadora_id,
            mercado_id: this.form.mercado_id,
            fecha_desde: this.form.fecha_desde,
            fecha_hasta: this.form.fecha_hasta
          }
        });
        if (res.data.success && res.data.data.url) {
          window.open(res.data.data.url, '_blank');
        } else {
          this.error = res.data.message || 'No se pudo exportar a Excel';
        }
      } catch (e) {
        this.error = e.message;
      } finally {
        this.loading = false;
      }
    }
  }
};
</script>

<style scoped>
.pagos-loc-grl-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: 1.5rem;
}
.breadcrumb {
  background: none;
  padding: 0;
  margin-bottom: 1rem;
}
</style>
