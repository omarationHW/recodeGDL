<template>
  <div class="firmas-page">
    <h1>Firmas para Oficios de Convenios</h1>
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Firmas</li>
      </ol>
    </nav>
    <div class="actions mb-3">
      <button class="btn btn-primary" @click="showCreate">Agregar</button>
      <button class="btn btn-secondary" :disabled="!selectedFirma" @click="showEdit">Editar</button>
      <button class="btn btn-danger" :disabled="!selectedFirma" @click="deleteFirma">Eliminar</button>
    </div>
    <table class="table table-striped">
      <thead>
        <tr>
          <th>Recaudadora</th>
          <th>Titular</th>
          <th>Cargo Titular</th>
          <th>Recaudador</th>
          <th>Cargo Recaudador</th>
          <th>Testigo 1</th>
          <th>Testigo 2</th>
          <th>Letras</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="firma in firmas" :key="firma.recaudadora" @click="selectFirma(firma)" :class="{selected: selectedFirma && selectedFirma.recaudadora === firma.recaudadora}">
          <td>{{ firma.recaudadora }}</td>
          <td>{{ firma.titular }}</td>
          <td>{{ firma.cargotitular }}</td>
          <td>{{ firma.recaudador }}</td>
          <td>{{ firma.cargorecaudador }}</td>
          <td>{{ firma.testigo1 }}</td>
          <td>{{ firma.testigo2 }}</td>
          <td>{{ firma.letras }}</td>
        </tr>
      </tbody>
    </table>
    <div v-if="showForm" class="modal-mask">
      <div class="modal-wrapper">
        <div class="modal-container">
          <h3>{{ isEdit ? 'Editar Firma' : 'Agregar Firma' }}</h3>
          <form @submit.prevent="submitForm">
            <div class="form-group">
              <label>Recaudadora</label>
              <input type="number" v-model.number="form.recaudadora" class="form-control" :readonly="isEdit" required />
            </div>
            <div class="form-group">
              <label>Titular</label>
              <input type="text" v-model="form.titular" class="form-control" required />
            </div>
            <div class="form-group">
              <label>Cargo Titular</label>
              <input type="text" v-model="form.cargotitular" class="form-control" required />
            </div>
            <div class="form-group">
              <label>Recaudador</label>
              <input type="text" v-model="form.recaudador" class="form-control" required />
            </div>
            <div class="form-group">
              <label>Cargo Recaudador</label>
              <input type="text" v-model="form.cargorecaudador" class="form-control" required />
            </div>
            <div class="form-group">
              <label>Testigo 1</label>
              <input type="text" v-model="form.testigo1" class="form-control" required />
            </div>
            <div class="form-group">
              <label>Testigo 2</label>
              <input type="text" v-model="form.testigo2" class="form-control" required />
            </div>
            <div class="form-group">
              <label>Letras</label>
              <input type="text" v-model="form.letras" class="form-control" maxlength="3" required />
            </div>
            <div class="form-group mt-3">
              <button type="submit" class="btn btn-success">Guardar</button>
              <button type="button" class="btn btn-secondary" @click="closeForm">Cancelar</button>
            </div>
          </form>
        </div>
      </div>
    </div>
    <div v-if="alert.message" :class="['alert', 'mt-3', alert.type]">{{ alert.message }}</div>
  </div>
</template>

<script>
export default {
  name: 'FirmasPage',
  data() {
    return {
      firmas: [],
      selectedFirma: null,
      showForm: false,
      isEdit: false,
      form: {
        recaudadora: '',
        titular: '',
        cargotitular: '',
        recaudador: '',
        cargorecaudador: '',
        testigo1: '',
        testigo2: '',
        letras: ''
      },
      alert: {
        message: '',
        type: ''
      }
    };
  },
  created() {
    this.fetchFirmas();
  },
  methods: {
    async fetchFirmas() {
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ action: 'list', entity: 'firmas' })
        });
        const json = await res.json();
        if (json.status === 'success') {
          this.firmas = json.data;
        } else {
          this.showAlert(json.message, 'alert-danger');
        }
      } catch (e) {
        this.showAlert('Error al cargar firmas', 'alert-danger');
      }
    },
    selectFirma(firma) {
      this.selectedFirma = firma;
    },
    showCreate() {
      this.isEdit = false;
      this.form = {
        recaudadora: '',
        titular: '',
        cargotitular: '',
        recaudador: '',
        cargorecaudador: '',
        testigo1: '',
        testigo2: '',
        letras: ''
      };
      this.showForm = true;
    },
    showEdit() {
      if (!this.selectedFirma) return;
      this.isEdit = true;
      this.form = { ...this.selectedFirma };
      this.showForm = true;
    },
    closeForm() {
      this.showForm = false;
    },
    async submitForm() {
      const action = this.isEdit ? 'update' : 'create';
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ action, entity: 'firmas', data: this.form })
        });
        const json = await res.json();
        if (json.status === 'success') {
          this.showAlert(json.message, 'alert-success');
          this.showForm = false;
          this.fetchFirmas();
        } else {
          this.showAlert(json.message, 'alert-danger');
        }
      } catch (e) {
        this.showAlert('Error al guardar', 'alert-danger');
      }
    },
    async deleteFirma() {
      if (!this.selectedFirma) return;
      if (!confirm('¿Está seguro de eliminar esta firma?')) return;
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ action: 'delete', entity: 'firmas', data: { recaudadora: this.selectedFirma.recaudadora } })
        });
        const json = await res.json();
        if (json.status === 'success') {
          this.showAlert(json.message, 'alert-success');
          this.selectedFirma = null;
          this.fetchFirmas();
        } else {
          this.showAlert(json.message, 'alert-danger');
        }
      } catch (e) {
        this.showAlert('Error al eliminar', 'alert-danger');
      }
    },
    showAlert(message, type) {
      this.alert.message = message;
      this.alert.type = type;
      setTimeout(() => { this.alert.message = ''; }, 4000);
    }
  }
};
</script>

<style scoped>
.firmas-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem;
}
.selected {
  background: #e3f2fd;
}
.modal-mask {
  position: fixed;
  z-index: 9998;
  top: 0; left: 0; right: 0; bottom: 0;
  background-color: rgba(0,0,0,0.5);
  display: flex;
  align-items: center;
  justify-content: center;
}
.modal-wrapper {
  width: 100%;
  max-width: 500px;
}
.modal-container {
  background: #fff;
  padding: 2rem;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.2);
}
.alert {
  padding: 1rem;
  border-radius: 4px;
}
.alert-success {
  background: #d4edda;
  color: #155724;
}
.alert-danger {
  background: #f8d7da;
  color: #721c24;
}
</style>
