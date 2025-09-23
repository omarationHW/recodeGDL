<template>
  <div class="multiple-rcm-page">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Consulta Múltiple por RCM</li>
      </ol>
    </nav>
    <h1>Consulta Múltiple por R.C.M</h1>
    <form @submit.prevent="onSearch">
      <div class="row">
        <div class="col-md-3">
          <label>Cementerio</label>
          <select v-model="form.cementerio" class="form-control" required>
            <option v-for="cem in cementerios" :key="cem.cementerio" :value="cem.cementerio">
              {{ cem.nombre }}
            </option>
          </select>
        </div>
        <div class="col-md-2">
          <label>Clase</label>
          <input type="number" v-model.number="form.clase" min="1" max="3" class="form-control" required />
        </div>
        <div class="col-md-2">
          <label>Clase Alfabético</label>
          <input type="text" v-model="form.clase_alfa" maxlength="10" class="form-control" />
        </div>
        <div class="col-md-2">
          <label>Sección</label>
          <input type="number" v-model.number="form.seccion" min="1" class="form-control" required />
        </div>
        <div class="col-md-2">
          <label>Sección Alfabético</label>
          <input type="text" v-model="form.seccion_alfa" maxlength="10" class="form-control" />
        </div>
      </div>
      <div class="row mt-2">
        <div class="col-md-2">
          <label>Línea</label>
          <input type="number" v-model.number="form.linea" min="1" class="form-control" required />
        </div>
        <div class="col-md-2">
          <label>Línea Alfabético</label>
          <input type="text" v-model="form.linea_alfa" maxlength="20" class="form-control" />
        </div>
        <div class="col-md-2">
          <label>Fosa</label>
          <input type="number" v-model.number="form.fosa" min="1" class="form-control" required />
        </div>
        <div class="col-md-2">
          <label>Fosa Alfabético</label>
          <input type="text" v-model="form.fosa_alfa" maxlength="20" class="form-control" />
        </div>
        <div class="col-md-2 align-self-end">
          <button type="submit" class="btn btn-primary">Buscar</button>
        </div>
      </div>
    </form>
    <div v-if="error" class="alert alert-danger mt-3">{{ error }}</div>
    <div v-if="results.length" class="mt-4">
      <h3>Resultados</h3>
      <table class="table table-bordered table-sm">
        <thead>
          <tr>
            <th>Folio</th>
            <th>Cementerio</th>
            <th>Clase</th>
            <th>Clase Alfa</th>
            <th>Sección</th>
            <th>Sección Alfa</th>
            <th>Línea</th>
            <th>Línea Alfa</th>
            <th>Fosa</th>
            <th>Fosa Alfa</th>
            <th>Nombre</th>
            <th>Domicilio</th>
            <th>Acciones</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in results" :key="row.control_rcm">
            <td>{{ row.control_rcm }}</td>
            <td>{{ row.cementerio }}</td>
            <td>{{ row.clase }}</td>
            <td>{{ row.clase_alfa }}</td>
            <td>{{ row.seccion }}</td>
            <td>{{ row.seccion_alfa }}</td>
            <td>{{ row.linea }}</td>
            <td>{{ row.linea_alfa }}</td>
            <td>{{ row.fosa }}</td>
            <td>{{ row.fosa_alfa }}</td>
            <td>{{ row.nombre }}</td>
            <td>{{ row.domicilio }}</td>
            <td>
              <button class="btn btn-sm btn-info" @click="viewDetail(row.control_rcm)">Ver detalle</button>
            </td>
          </tr>
        </tbody>
      </table>
      <button v-if="results.length === 100" class="btn btn-secondary" @click="continueSearch">Continuar búsqueda</button>
    </div>
    <div v-if="showDetail && detail" class="modal fade show d-block" tabindex="-1" style="background:rgba(0,0,0,0.2)">
      <div class="modal-dialog modal-lg">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">Detalle RCM Folio {{ detail.control_rcm }}</h5>
            <button type="button" class="btn-close" @click="showDetail=false"></button>
          </div>
          <div class="modal-body">
            <pre>{{ detail }}</pre>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'MultipleRCMPage',
  data() {
    return {
      cementerios: [],
      form: {
        cementerio: '',
        clase: 1,
        clase_alfa: '',
        seccion: 1,
        seccion_alfa: '',
        linea: 1,
        linea_alfa: '',
        fosa: 1,
        fosa_alfa: '',
        cuenta: 0
      },
      results: [],
      error: '',
      showDetail: false,
      detail: null
    };
  },
  created() {
    this.fetchCementerios();
  },
  methods: {
    async fetchCementerios() {
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'cementerios.getCementerios',
          payload: {}
        });
        if (res.data.status === 'success') {
          this.cementerios = res.data.data;
          if (this.cementerios.length) {
            this.form.cementerio = this.cementerios[0].cementerio;
          }
        } else {
          throw new Error(res.data.message || 'Error en la solicitud');
        }
      } catch (error) {
        this.error = error.response?.data?.message || error.message || 'Error cargando cementerios';
      }
    },
    async onSearch() {
      this.error = '';
      this.form.cuenta = 0;
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'cementerios.searchRCM',
          payload: this.form
        });
        if (res.data.status === 'success') {
          this.results = res.data.data;
          if (!this.results.length) {
            this.error = 'No existe registro con esos datos';
          }
        } else {
          throw new Error(res.data.message || 'Error en la búsqueda');
        }
      } catch (error) {
        this.error = error.response?.data?.message || error.message || 'Error en la búsqueda';
      }
    },
    async continueSearch() {
      if (!this.results.length) return;
      const last = this.results[this.results.length - 1];
      this.form.cuenta = last.control_rcm;
      await this.onSearch();
    },
    async viewDetail(control_rcm) {
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'cementerios.getRCMById',
          payload: { control_rcm }
        });
        if (res.data.status === 'success' && res.data.data.length) {
          this.detail = res.data.data[0];
          this.showDetail = true;
        } else {
          throw new Error(res.data.message || 'Error en la solicitud');
        }
      } catch (error) {
        this.error = error.response?.data?.message || error.message || 'Error cargando detalle';
      }
    }
  }
};
</script>

<style scoped>
.multiple-rcm-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem 1rem;
}
.breadcrumb {
  background: none;
  padding: 0;
  margin-bottom: 1rem;
}
.modal {
  display: block;
}
</style>
