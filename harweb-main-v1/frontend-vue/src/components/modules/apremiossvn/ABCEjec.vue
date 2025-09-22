<template>
  <div class="container">
    <h1>Catálogo de Ejecutores</h1>
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Ejecutores</li>
      </ol>
    </nav>
    <div class="row mb-3">
      <div class="col-md-3">
        <label>Recaudadora</label>
        <select v-model="selectedRec" class="form-control" @change="fetchList">
          <option v-for="rec in recaudadoras" :key="rec.id_rec" :value="rec.id_rec">{{ rec.id_rec }} - {{ rec.recaudadora }}</option>
        </select>
      </div>
      <div class="col-md-9 text-right">
        <button class="btn btn-success" @click="showForm('create')">Nuevo Ejecutor</button>
      </div>
    </div>
    <table class="table table-striped">
      <thead>
        <tr>
          <th>#</th>
          <th>Nombre</th>
          <th>RFC</th>
          <th>Oficio</th>
          <th>Fec. Inicio</th>
          <th>Fec. Termino</th>
          <th>Vigencia</th>
          <th>Acciones</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="ej in ejecutores" :key="ej.cve_eje">
          <td>{{ ej.cve_eje }}</td>
          <td>{{ ej.nombre }}</td>
          <td>{{ ej.ini_rfc }}{{ ej.fec_rfc | fechaRFC }}{{ ej.hom_rfc }}</td>
          <td>{{ ej.oficio }}</td>
          <td>{{ ej.fecinic | fecha }}</td>
          <td>{{ ej.fecterm | fecha }}</td>
          <td>
            <span :class="{'badge badge-success': ej.vigencia==='A', 'badge badge-danger': ej.vigencia==='B'}">
              {{ ej.vigencia==='A' ? 'Activo' : 'Baja' }}
            </span>
          </td>
          <td>
            <button class="btn btn-primary btn-sm" @click="showForm('edit', ej)">Editar</button>
            <button class="btn btn-warning btn-sm" @click="toggleVigencia(ej)">
              {{ ej.vigencia==='A' ? 'Dar de Baja' : 'Reactivar' }}
            </button>
          </td>
        </tr>
      </tbody>
    </table>
    <div v-if="showModal">
      <div class="modal-backdrop show"></div>
      <div class="modal d-block" tabindex="-1">
        <div class="modal-dialog">
          <div class="modal-content">
            <div class="modal-header">
              <h5 class="modal-title">{{ formMode==='create' ? 'Nuevo Ejecutor' : 'Editar Ejecutor' }}</h5>
              <button type="button" class="close" @click="closeForm">&times;</button>
            </div>
            <div class="modal-body">
              <form @submit.prevent="submitForm">
                <div class="form-group">
                  <label>Número Ejecutor</label>
                  <input type="number" v-model="form.cve_eje" class="form-control" :readonly="formMode==='edit'">
                </div>
                <div class="form-group">
                  <label>Nombre</label>
                  <input type="text" v-model="form.nombre" class="form-control" required>
                </div>
                <div class="form-row">
                  <div class="form-group col-md-4">
                    <label>RFC Iniciales</label>
                    <input type="text" v-model="form.ini_rfc" maxlength="4" class="form-control" required>
                  </div>
                  <div class="form-group col-md-4">
                    <label>RFC Fecha</label>
                    <input type="date" v-model="form.fec_rfc" class="form-control" required>
                  </div>
                  <div class="form-group col-md-4">
                    <label>RFC Homoclave</label>
                    <input type="text" v-model="form.hom_rfc" maxlength="3" class="form-control" required>
                  </div>
                </div>
                <div class="form-group">
                  <label>Oficio</label>
                  <input type="text" v-model="form.oficio" class="form-control" required>
                </div>
                <div class="form-row">
                  <div class="form-group col-md-6">
                    <label>Fecha Inicio</label>
                    <input type="date" v-model="form.fecinic" class="form-control" required>
                  </div>
                  <div class="form-group col-md-6">
                    <label>Fecha Termino</label>
                    <input type="date" v-model="form.fecterm" class="form-control" required>
                  </div>
                </div>
                <div class="form-group">
                  <label>Recaudadora</label>
                  <select v-model="form.id_rec" class="form-control" required>
                    <option v-for="rec in recaudadoras" :key="rec.id_rec" :value="rec.id_rec">{{ rec.id_rec }} - {{ rec.recaudadora }}</option>
                  </select>
                </div>
                <div class="form-group text-right">
                  <button type="submit" class="btn btn-success">Guardar</button>
                  <button type="button" class="btn btn-secondary" @click="closeForm">Cancelar</button>
                </div>
              </form>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'EjecutoresPage',
  data() {
    return {
      ejecutores: [],
      recaudadoras: [],
      selectedRec: null,
      showModal: false,
      formMode: 'create',
      form: {
        cve_eje: '',
        ini_rfc: '',
        fec_rfc: '',
        hom_rfc: '',
        nombre: '',
        id_rec: '',
        oficio: '',
        fecinic: '',
        fecterm: ''
      }
    }
  },
  filters: {
    fecha(val) {
      if (!val) return '';
      return new Date(val).toLocaleDateString();
    },
    fechaRFC(val) {
      if (!val) return '';
      // Formato RFC: yymmdd
      const d = new Date(val);
      return d.getFullYear().toString().slice(2,4) + (d.getMonth()+1).toString().padStart(2,'0') + d.getDate().toString().padStart(2,'0');
    }
  },
  mounted() {
    this.fetchRecaudadoras();
  },
  methods: {
    fetchRecaudadoras() {
      // Simulación: en producción, usar API
      this.$axios.post('/api/execute', {
        eRequest: { action: 'list_recaudadoras', params: {} }
      }).then(resp => {
        this.recaudadoras = resp.data.eResponse.result;
        if (this.recaudadoras.length > 0) {
          this.selectedRec = this.recaudadoras[0].id_rec;
          this.fetchList();
        }
      });
    },
    fetchList() {
      this.$axios.post('/api/execute', {
        eRequest: { action: 'list', params: { id_rec: this.selectedRec } }
      }).then(resp => {
        this.ejecutores = resp.data.eResponse.result;
      });
    },
    showForm(mode, ej = null) {
      this.formMode = mode;
      if (mode === 'edit' && ej) {
        this.form = { ...ej };
      } else {
        this.form = {
          cve_eje: '', ini_rfc: '', fec_rfc: '', hom_rfc: '', nombre: '', id_rec: this.selectedRec, oficio: '', fecinic: '', fecterm: ''
        };
      }
      this.showModal = true;
    },
    closeForm() {
      this.showModal = false;
    },
    submitForm() {
      const action = this.formMode === 'create' ? 'create' : 'update';
      this.$axios.post('/api/execute', {
        eRequest: { action, params: this.form }
      }).then(resp => {
        if (!resp.data.eResponse.error) {
          this.fetchList();
          this.showModal = false;
        } else {
          alert('Error: ' + resp.data.eResponse.error);
        }
      });
    },
    toggleVigencia(ej) {
      if (!confirm('¿Está seguro de cambiar la vigencia de este ejecutor?')) return;
      this.$axios.post('/api/execute', {
        eRequest: { action: 'toggle_vigencia', params: { cve_eje: ej.cve_eje, id_rec: ej.id_rec } }
      }).then(resp => {
        if (!resp.data.eResponse.error) {
          this.fetchList();
        } else {
          alert('Error: ' + resp.data.eResponse.error);
        }
      });
    }
  }
}
</script>

<style scoped>
.container { max-width: 900px; margin: 0 auto; }
.modal-backdrop { position: fixed; top:0; left:0; width:100vw; height:100vh; background:rgba(0,0,0,0.3); z-index: 1040; }
.modal { z-index: 1050; }
</style>
