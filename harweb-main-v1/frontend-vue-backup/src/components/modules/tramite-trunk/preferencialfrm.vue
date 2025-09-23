<template>
  <div class="preferencial-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Tasa Preferencial</li>
      </ol>
    </nav>
    <h2>Autoriza tasa preferencial en Transmisiones Patrimoniales con tasa irregular</h2>
    <div class="mb-3">
      <label for="folio">Folio de Trámite</label>
      <input v-model="folio" id="folio" type="number" class="form-control" @change="fetchPreferencialList" />
    </div>
    <div v-if="preferencialList.length">
      <table class="table table-bordered table-sm">
        <thead>
          <tr>
            <th>Folio</th>
            <th>Bimestre</th>
            <th>Año Efectos</th>
            <th>Comprobante</th>
            <th>Año</th>
            <th>Status</th>
            <th>Escrituras</th>
            <th>Otorgamiento</th>
            <th>Firma</th>
            <th>Adjudicación</th>
            <th>Valor Operación</th>
            <th>Exenta</th>
            <th>Fecha Entrada</th>
            <th>Fecha Trámite</th>
            <th>Capturista</th>
            <th>Tasa Irregular</th>
            <th>Tasa Actualizada</th>
            <th>Autorizado</th>
            <th>Dado de Baja</th>
            <th>Observaciones</th>
            <th>Acciones</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="item in preferencialList" :key="item.id">
            <td>{{ item.folio }}</td>
            <td>{{ item.bimefec }}</td>
            <td>{{ item.axoefec }}</td>
            <td>{{ item.nocomp }}</td>
            <td>{{ item.axocomp }}</td>
            <td>{{ item.nstatus }}</td>
            <td>{{ item.noescrituras }}</td>
            <td>{{ item.fechaotorg }}</td>
            <td>{{ item.fechafirma }}</td>
            <td>{{ item.fechaadjudicacion }}</td>
            <td>{{ item.valortransm }}</td>
            <td>{{ item.exento }}</td>
            <td>{{ item.feccap }}</td>
            <td>{{ item.fectram }}</td>
            <td>{{ item.capturista }}</td>
            <td>{{ item.tasa }}</td>
            <td>{{ item.tasa_nva }}</td>
            <td>{{ item.feccap }}</td>
            <td>{{ item.fecha_baja }}</td>
            <td>{{ item.observacion }}</td>
            <td>
              <button class="btn btn-sm btn-primary" @click="editPreferencial(item)">Editar</button>
              <button class="btn btn-sm btn-danger" @click="bajaPreferencial(item)" v-if="!item.fecha_baja">Dar de Baja</button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    <div v-if="showForm">
      <h4>{{ formMode === 'add' ? 'Agregar' : 'Editar' }} Tasa Preferencial</h4>
      <form @submit.prevent="submitForm">
        <div class="row">
          <div class="col-md-4">
            <label>Tasa Irregular</label>
            <input v-model="form.tasa_nva" type="number" step="0.00001" class="form-control" required />
          </div>
          <div class="col-md-4">
            <label>Tasas Válidas</label>
            <select v-model="form.tasa_nva" class="form-control">
              <option v-for="t in tasasValidas" :key="t.tasaporcen" :value="t.tasaporcen">{{ t.tasaporcen }}</option>
            </select>
          </div>
          <div class="col-md-4">
            <label>Observaciones</label>
            <textarea v-model="form.observacion" class="form-control" rows="2"></textarea>
          </div>
        </div>
        <div class="mt-3">
          <button type="submit" class="btn btn-success">Aceptar</button>
          <button type="button" class="btn btn-secondary" @click="cancelForm">Cancelar</button>
        </div>
      </form>
    </div>
    <div class="mt-4">
      <button class="btn btn-primary" @click="showAddForm">Agregar Tasa Preferencial</button>
    </div>
  </div>
</template>

<script>
export default {
  name: 'PreferencialPage',
  data() {
    return {
      folio: '',
      preferencialList: [],
      tasasValidas: [],
      showForm: false,
      formMode: 'add',
      form: {
        id: null,
        folio: '',
        tasa_nva: '',
        observacion: '',
        axoefec: '',
        user: ''
      }
    };
  },
  methods: {
    fetchPreferencialList() {
      if (!this.folio) return;
      this.$axios.post('/api/execute', {
        action: 'getPreferencialList',
        payload: { folio: this.folio }
      }).then(res => {
        if (res.data.success) {
          this.preferencialList = res.data.data;
          if (this.preferencialList.length > 0) {
            this.form.axoefec = this.preferencialList[0].axoefec;
            this.fetchTasasValidas(this.form.axoefec);
          }
        }
      });
    },
    fetchTasasValidas(axoefec) {
      this.$axios.post('/api/execute', {
        action: 'getTasasValidas',
        payload: { axoefec }
      }).then(res => {
        if (res.data.success) {
          this.tasasValidas = res.data.data;
        }
      });
    },
    showAddForm() {
      this.formMode = 'add';
      this.showForm = true;
      this.form = {
        id: null,
        folio: this.folio,
        tasa_nva: '',
        observacion: '',
        axoefec: this.form.axoefec,
        user: this.$store.state.user.username
      };
    },
    editPreferencial(item) {
      this.formMode = 'edit';
      this.showForm = true;
      this.form = {
        id: item.id,
        folio: item.folio,
        tasa_nva: item.tasa_nva,
        observacion: item.observacion,
        axoefec: item.axoefec,
        user: this.$store.state.user.username
      };
    },
    bajaPreferencial(item) {
      if (!confirm('¿Está seguro de dar de baja esta tasa preferencial?')) return;
      this.$axios.post('/api/execute', {
        action: 'bajaPreferencial',
        payload: {
          id: item.id,
          user_baja: this.$store.state.user.username
        }
      }).then(res => {
        if (res.data.success) {
          this.fetchPreferencialList();
        } else {
          alert(res.data.message);
        }
      });
    },
    submitForm() {
      if (this.formMode === 'add') {
        this.$axios.post('/api/execute', {
          action: 'addPreferencial',
          payload: this.form
        }).then(res => {
          if (res.data.success) {
            this.showForm = false;
            this.fetchPreferencialList();
          } else {
            alert(res.data.message);
          }
        });
      } else if (this.formMode === 'edit') {
        this.$axios.post('/api/execute', {
          action: 'updatePreferencial',
          payload: this.form
        }).then(res => {
          if (res.data.success) {
            this.showForm = false;
            this.fetchPreferencialList();
          } else {
            alert(res.data.message);
          }
        });
      }
    },
    cancelForm() {
      this.showForm = false;
    }
  }
};
</script>

<style scoped>
.preferencial-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem;
}
</style>
