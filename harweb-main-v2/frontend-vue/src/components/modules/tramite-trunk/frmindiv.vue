<template>
  <div class="frm-indiv-page">
    <h1>Construcciones Individuales</h1>
    <div class="breadcrumb">
      <router-link to="/">Inicio</router-link> /
      <span>Construcciones Individuales</span>
    </div>
    <div class="search-section">
      <label for="cvecatnva">Clave Catastral:</label>
      <input v-model="cvecatnva" id="cvecatnva" maxlength="11" @keyup.enter="fetchList" />
      <button @click="fetchList">Buscar</button>
    </div>
    <div v-if="loading" class="loading">Cargando...</div>
    <div v-if="error" class="error">{{ error }}</div>
    <div v-if="list.length">
      <table class="data-table">
        <thead>
          <tr>
            <th>Clave Catastral</th>
            <th>Sub Predio</th>
            <th>No. Bloque</th>
            <th>Año Construcción</th>
            <th>Área Const.</th>
            <th>Clasificación</th>
            <th>Cuenta</th>
            <th>Estructura</th>
            <th>Factor Ajus.</th>
            <th>No. Pisos</th>
            <th>Importe</th>
            <th>Cve. Avalúo</th>
            <th>Vigencia</th>
            <th>Acciones</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="item in list" :key="item.id">
            <td>{{ item.cvecatnva }}</td>
            <td>{{ item.subpredio }}</td>
            <td>{{ item.cvebloque }}</td>
            <td>{{ item.axoconst }}</td>
            <td>{{ item.areaconst }}</td>
            <td>{{ item.cveclasif }}</td>
            <td>{{ item.cvecuenta }}</td>
            <td>{{ item.estructura }}</td>
            <td>{{ item.factorajus }}</td>
            <td>{{ item.numpisos }}</td>
            <td>{{ item.importe }}</td>
            <td>{{ item.cveavaluo }}</td>
            <td>{{ item.axovig }}</td>
            <td>
              <button @click="editItem(item)">Editar</button>
              <button @click="deleteItem(item)">Eliminar</button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    <div v-else-if="!loading && cvecatnva">No hay construcciones individuales para esta clave.</div>
    <div class="form-section">
      <h2 v-if="form.id">Editar Construcción</h2>
      <h2 v-else>Agregar Construcción</h2>
      <form @submit.prevent="saveItem">
        <div class="form-row">
          <label>Clave Catastral:</label>
          <input v-model="form.cvecatnva" maxlength="11" required :readonly="!!form.id" />
        </div>
        <div class="form-row">
          <label>Sub Predio:</label>
          <input v-model.number="form.subpredio" type="number" min="1" required />
        </div>
        <div class="form-row">
          <label>No. Bloque:</label>
          <input v-model.number="form.cvebloque" type="number" required />
        </div>
        <div class="form-row">
          <label>Año Construcción:</label>
          <input v-model.number="form.axoconst" type="number" required />
        </div>
        <div class="form-row">
          <label>Área Const.:</label>
          <input v-model.number="form.areaconst" type="number" step="0.01" required />
        </div>
        <div class="form-row">
          <label>Clasificación:</label>
          <input v-model.number="form.cveclasif" type="number" required />
        </div>
        <div class="form-row">
          <label>Cuenta:</label>
          <input v-model.number="form.cvecuenta" type="number" required />
        </div>
        <div class="form-row">
          <label>Estructura:</label>
          <input v-model.number="form.estructura" type="number" />
        </div>
        <div class="form-row">
          <label>Factor Ajus.:</label>
          <input v-model.number="form.factorajus" type="number" step="0.01" />
        </div>
        <div class="form-row">
          <label>No. Pisos:</label>
          <input v-model.number="form.numpisos" type="number" />
        </div>
        <div class="form-row">
          <label>Importe:</label>
          <input v-model.number="form.importe" type="number" step="0.01" />
        </div>
        <div class="form-row">
          <label>Cve. Avalúo:</label>
          <input v-model.number="form.cveavaluo" type="number" />
        </div>
        <div class="form-row">
          <label>Vigencia:</label>
          <input v-model.number="form.axovig" type="number" />
        </div>
        <div class="form-actions">
          <button type="submit">{{ form.id ? 'Actualizar' : 'Agregar' }}</button>
          <button type="button" @click="resetForm">Cancelar</button>
        </div>
      </form>
    </div>
  </div>
</template>

<script>
export default {
  name: 'FrmIndivPage',
  data() {
    return {
      cvecatnva: '',
      list: [],
      loading: false,
      error: '',
      form: {
        id: null,
        cvecatnva: '',
        subpredio: '',
        cvebloque: '',
        axoconst: '',
        areaconst: '',
        cveclasif: '',
        cvecuenta: '',
        estructura: '',
        factorajus: '',
        numpisos: '',
        importe: '',
        cveavaluo: '',
        axovig: ''
      }
    }
  },
  methods: {
    async fetchList() {
      if (!this.cvecatnva || this.cvecatnva.length < 11) {
        this.error = 'Debe ingresar la clave catastral completa (11 dígitos)';
        return;
      }
      this.loading = true;
      this.error = '';
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            action: 'list',
            params: { cvecatnva: this.cvecatnva }
          })
        });
        const data = await res.json();
        if (data.success) {
          this.list = data.data;
        } else {
          this.error = data.message || 'Error al consultar.';
        }
      } catch (e) {
        this.error = e.message;
      } finally {
        this.loading = false;
      }
    },
    editItem(item) {
      this.form = { ...item };
    },
    async deleteItem(item) {
      if (!confirm('¿Está seguro de eliminar esta construcción?')) return;
      this.loading = true;
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            action: 'delete',
            params: { id: item.id }
          })
        });
        const data = await res.json();
        if (data.success) {
          this.fetchList();
          this.resetForm();
        } else {
          this.error = data.message || 'Error al eliminar.';
        }
      } catch (e) {
        this.error = e.message;
      } finally {
        this.loading = false;
      }
    },
    async saveItem() {
      this.loading = true;
      this.error = '';
      try {
        const action = this.form.id ? 'update' : 'create';
        const params = { ...this.form };
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ action, params })
        });
        const data = await res.json();
        if (data.success) {
          this.fetchList();
          this.resetForm();
        } else {
          this.error = data.message || 'Error al guardar.';
        }
      } catch (e) {
        this.error = e.message;
      } finally {
        this.loading = false;
      }
    },
    resetForm() {
      this.form = {
        id: null,
        cvecatnva: this.cvecatnva,
        subpredio: '',
        cvebloque: '',
        axoconst: '',
        areaconst: '',
        cveclasif: '',
        cvecuenta: '',
        estructura: '',
        factorajus: '',
        numpisos: '',
        importe: '',
        cveavaluo: '',
        axovig: ''
      };
    }
  }
}
</script>

<style scoped>
.frm-indiv-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: 24px;
}
.breadcrumb {
  margin-bottom: 16px;
}
.search-section {
  margin-bottom: 24px;
}
.data-table {
  width: 100%;
  border-collapse: collapse;
  margin-bottom: 24px;
}
.data-table th, .data-table td {
  border: 1px solid #ccc;
  padding: 4px 8px;
  font-size: 13px;
}
.data-table th {
  background: #f5f5f5;
}
.form-section {
  background: #f9f9f9;
  padding: 16px;
  border-radius: 6px;
  max-width: 600px;
}
.form-row {
  margin-bottom: 10px;
  display: flex;
  align-items: center;
}
.form-row label {
  width: 160px;
  font-weight: bold;
}
.form-row input {
  flex: 1;
  padding: 4px;
}
.form-actions {
  margin-top: 16px;
  display: flex;
  gap: 12px;
}
.loading {
  color: #888;
  font-style: italic;
}
.error {
  color: #b00;
  margin-bottom: 12px;
}
</style>
