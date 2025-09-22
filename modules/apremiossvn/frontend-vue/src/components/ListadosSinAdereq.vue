<template>
  <div class="listados-sin-adereq-page">
    <h1>Listado de Requerimientos sin Adeudos</h1>
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Listados Sin Adeudos</li>
      </ol>
    </nav>
    <form @submit.prevent="buscar">
      <div class="row mb-3">
        <div class="col-md-3">
          <label>Aplicación</label>
          <select v-model="form.tipo" class="form-control">
            <option value="mercado">Mercados</option>
            <option value="aseo">Aseo</option>
          </select>
        </div>
        <div class="col-md-3">
          <label>Recaudadora</label>
          <select v-model="form.id_rec" class="form-control" @change="onRecaudadoraChange">
            <option v-for="rec in recaudadoras" :key="rec.id_rec" :value="rec.id_rec">{{ rec.id_rec }} - {{ rec.recaudadora }}</option>
          </select>
        </div>
        <div class="col-md-3" v-if="form.tipo === 'mercado'">
          <label>Mercado</label>
          <select v-model="form.num_mercado" class="form-control" @change="onMercadoChange">
            <option v-for="merc in mercados" :key="merc.num_mercado_nvo" :value="merc.num_mercado_nvo">{{ merc.num_mercado_nvo }} - {{ merc.descripcion }}</option>
          </select>
        </div>
        <div class="col-md-3" v-if="form.tipo === 'mercado'">
          <label>Sección</label>
          <select v-model="form.seccion" class="form-control">
            <option value="todas">Todas</option>
            <option v-for="secc in secciones" :key="secc.seccion" :value="secc.seccion">{{ secc.seccion }} - {{ secc.descripcion }}</option>
          </select>
        </div>
      </div>
      <div class="row mb-3">
        <div class="col-md-2">
          <label>Local desde</label>
          <input type="number" v-model.number="form.local1" class="form-control" min="1" />
        </div>
        <div class="col-md-2">
          <label>Local hasta</label>
          <input type="number" v-model.number="form.local2" class="form-control" min="1" />
        </div>
        <div class="col-md-2 align-self-end">
          <button type="submit" class="btn btn-primary">Buscar</button>
        </div>
      </div>
    </form>
    <div v-if="loading" class="alert alert-info">Cargando...</div>
    <div v-if="error" class="alert alert-danger">{{ error }}</div>
    <div v-if="resultados.length">
      <h3>Resultados</h3>
      <table class="table table-sm table-bordered">
        <thead>
          <tr>
            <th>ID Local</th>
            <th>Oficina</th>
            <th>Mercado</th>
            <th>Sección</th>
            <th>Local</th>
            <th>Nombre</th>
            <th>Arrendatario</th>
            <th>Importe</th>
            <th>Recargos</th>
            <th>Renta</th>
            <th>Total Gasto</th>
            <th>Bloqueos</th>
            <th>Último Movimiento</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in resultados" :key="row.id_local">
            <td>{{ row.id_local }}</td>
            <td>{{ row.oficina }}</td>
            <td>{{ row.num_mercado }}</td>
            <td>{{ row.seccion }}</td>
            <td>{{ row.local }}</td>
            <td>{{ row.nombre }}</td>
            <td>{{ row.arrendatario }}</td>
            <td>{{ row.importe | currency }}</td>
            <td>{{ row.recargos | currency }}</td>
            <td>{{ row.renta | currency }}</td>
            <td>{{ row.total_gasto | currency }}</td>
            <td>
              <button class="btn btn-link btn-sm" @click="verBloqueos(row.id_local)">Ver</button>
            </td>
            <td>
              <button class="btn btn-link btn-sm" @click="verUltimoMovimiento(row.id_local)">Ver</button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    <div v-if="bloqueos.length">
      <h4>Bloqueos del Local {{ bloqueos[0]?.id_local }}</h4>
      <table class="table table-sm table-bordered">
        <thead>
          <tr>
            <th>Tipo</th>
            <th>Fecha Inicio</th>
            <th>Fecha Final</th>
            <th>Observación</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="b in bloqueos" :key="b.id_local + '-' + b.cve_bloqueo">
            <td>{{ b.tipob }}</td>
            <td>{{ b.fecha_inicio }}</td>
            <td>{{ b.fecha_final }}</td>
            <td>{{ b.observacion }}</td>
          </tr>
        </tbody>
      </table>
    </div>
    <div v-if="ultimoMovimiento">
      <h4>Último Movimiento del Local {{ ultimoMovimiento.control_otr }}</h4>
      <ul>
        <li>Folio: {{ ultimoMovimiento.folio }}</li>
        <li>Diligencia: {{ ultimoMovimiento.diligencia }}</li>
        <li>Importe Global: {{ ultimoMovimiento.importe_global | currency }}</li>
        <li>Fecha Emisión: {{ ultimoMovimiento.fecha_emision }}</li>
        <li>Vigencia: {{ ultimoMovimiento.vigen }}</li>
      </ul>
    </div>
  </div>
</template>

<script>
export default {
  name: 'ListadosSinAdereq',
  data() {
    return {
      recaudadoras: [],
      mercados: [],
      secciones: [],
      resultados: [],
      bloqueos: [],
      ultimoMovimiento: null,
      loading: false,
      error: '',
      form: {
        tipo: 'mercado',
        id_rec: null,
        num_mercado: null,
        seccion: 'todas',
        local1: 1,
        local2: 9999
      }
    };
  },
  filters: {
    currency(val) {
      if (typeof val !== 'number') return val;
      return '$' + val.toLocaleString('es-MX', { minimumFractionDigits: 2 });
    }
  },
  created() {
    this.fetchRecaudadoras();
  },
  methods: {
    async fetchRecaudadoras() {
      this.loading = true;
      try {
        const res = await this.$axios.post('/api/execute', { action: 'getRecaudadoras' });
        this.recaudadoras = res.data.data;
        if (this.recaudadoras.length) {
          this.form.id_rec = this.recaudadoras[0].id_rec;
          await this.onRecaudadoraChange();
        }
      } catch (e) {
        this.error = 'Error cargando recaudadoras';
      } finally {
        this.loading = false;
      }
    },
    async onRecaudadoraChange() {
      if (!this.form.id_rec) return;
      this.loading = true;
      try {
        const res = await this.$axios.post('/api/execute', { action: 'getMercados', params: { id_rec: this.form.id_rec } });
        this.mercados = res.data.data;
        if (this.mercados.length) {
          this.form.num_mercado = this.mercados[0].num_mercado_nvo;
          await this.onMercadoChange();
        }
      } catch (e) {
        this.error = 'Error cargando mercados';
      } finally {
        this.loading = false;
      }
    },
    async onMercadoChange() {
      if (!this.form.num_mercado) return;
      this.loading = true;
      try {
        const res = await this.$axios.post('/api/execute', { action: 'getSecciones', params: { num_mercado_nvo: this.form.num_mercado } });
        this.secciones = res.data.data;
      } catch (e) {
        this.error = 'Error cargando secciones';
      } finally {
        this.loading = false;
      }
    },
    async buscar() {
      this.loading = true;
      this.error = '';
      this.resultados = [];
      this.bloqueos = [];
      this.ultimoMovimiento = null;
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'getListadosSinAdereq',
          params: {
            tipo: this.form.tipo,
            id_rec: this.form.id_rec,
            num_mercado: this.form.num_mercado,
            seccion: this.form.seccion,
            local1: this.form.local1,
            local2: this.form.local2
          }
        });
        this.resultados = res.data.data;
      } catch (e) {
        this.error = 'Error buscando resultados';
      } finally {
        this.loading = false;
      }
    },
    async verBloqueos(id_local) {
      this.loading = true;
      try {
        const res = await this.$axios.post('/api/execute', { action: 'getBloqueos', params: { id_local } });
        this.bloqueos = res.data.data;
      } catch (e) {
        this.error = 'Error consultando bloqueos';
      } finally {
        this.loading = false;
      }
    },
    async verUltimoMovimiento(id_local) {
      this.loading = true;
      try {
        const res = await this.$axios.post('/api/execute', { action: 'getUltimoMovimiento', params: { id_local } });
        this.ultimoMovimiento = res.data.data[0] || null;
      } catch (e) {
        this.error = 'Error consultando último movimiento';
      } finally {
        this.loading = false;
      }
    }
  }
};
</script>

<style scoped>
.listados-sin-adereq-page {
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
