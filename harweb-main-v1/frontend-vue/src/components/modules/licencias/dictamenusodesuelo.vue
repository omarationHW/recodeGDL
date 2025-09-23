<template>
  <div class="dictamenusodesuelo-page">
    <h1>Dictamen de Uso de Suelo</h1>
    <div class="breadcrumb">
      <router-link to="/">Inicio</router-link> /
      <span>Dictamen de Uso de Suelo</span>
    </div>
    <div class="actions">
      <button @click="nuevo">Nueva Constancia</button>
      <button @click="buscar">Buscar</button>
      <button @click="listar">Listado</button>
    </div>
    <div v-if="formVisible" class="form-panel">
      <form @submit.prevent="guardar">
        <div class="form-row">
          <label>Solicita:</label>
          <input v-model="form.solicita" required />
        </div>
        <div class="form-row">
          <label>Partida de Pago:</label>
          <input v-model="form.partidapago" />
        </div>
        <div class="form-row">
          <label>Observación:</label>
          <input v-model="form.observacion" />
        </div>
        <div class="form-row">
          <label>Domicilio:</label>
          <input v-model="form.domicilio" />
        </div>
        <div class="form-row">
          <label>Licencia:</label>
          <input v-model="form.licencia" />
        </div>
        <div class="form-row">
          <label>Tipo:</label>
          <select v-model="form.tipo">
            <option value="0">Licencia</option>
            <option value="1">No Licencia</option>
            <option value="2">No Licencia Propietario</option>
            <option value="3">No Licencia Vigente</option>
          </select>
        </div>
        <div class="form-row">
          <label>Capturista:</label>
          <input v-model="form.capturista" />
        </div>
        <div class="form-row">
          <button type="submit">Guardar</button>
          <button type="button" @click="cancelar">Cancelar</button>
        </div>
      </form>
    </div>
    <div v-if="listadoVisible" class="listado-panel">
      <h2>Listado de Constancias</h2>
      <table>
        <thead>
          <tr>
            <th>Año</th>
            <th>Folio</th>
            <th>Licencia</th>
            <th>Solicita</th>
            <th>Observación</th>
            <th>Vigente</th>
            <th>Fecha</th>
            <th>Capturista</th>
            <th>Acciones</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="item in listado" :key="item.axo + '-' + item.folio">
            <td>{{ item.axo }}</td>
            <td>{{ item.folio }}</td>
            <td>{{ item.licencia }}</td>
            <td>{{ item.solicita }}</td>
            <td>{{ item.observacion }}</td>
            <td>{{ item.vigente === 'V' ? 'Vigente' : 'Cancelado' }}</td>
            <td>{{ item.feccap }}</td>
            <td>{{ item.capturista }}</td>
            <td>
              <button @click="editar(item)">Editar</button>
              <button @click="imprimir(item)">Imprimir</button>
              <button @click="cancelarConstancia(item)" v-if="item.vigente === 'V'">Cancelar</button>
            </td>
          </tr>
        </tbody>
      </table>
      <div class="pagination">
        <!-- Paginación si es necesario -->
      </div>
    </div>
    <div v-if="mensaje" class="mensaje">
      {{ mensaje }}
    </div>
  </div>
</template>

<script>
export default {
  name: 'DictamenUsoDeSueloPage',
  data() {
    return {
      formVisible: false,
      listadoVisible: true,
      form: {
        solicita: '',
        partidapago: '',
        observacion: '',
        domicilio: '',
        licencia: '',
        tipo: 0,
        capturista: ''
      },
      listado: [],
      mensaje: ''
    };
  },
  created() {
    this.listar();
  },
  methods: {
    async listar() {
      this.formVisible = false;
      this.listadoVisible = true;
      this.mensaje = '';
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          eRequest: {
            action: 'list',
            data: {}
          }
        })
      });
      const json = await res.json();
      if (json.eResponse.success) {
        this.listado = json.eResponse.data;
      } else {
        this.mensaje = json.eResponse.error;
      }
    },
    nuevo() {
      this.form = {
        solicita: '',
        partidapago: '',
        observacion: '',
        domicilio: '',
        licencia: '',
        tipo: 0,
        capturista: ''
      };
      this.formVisible = true;
      this.listadoVisible = false;
      this.mensaje = '';
    },
    async guardar() {
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          eRequest: {
            action: 'create',
            data: this.form
          }
        })
      });
      const json = await res.json();
      if (json.eResponse.success) {
        this.mensaje = 'Guardado correctamente';
        this.listar();
      } else {
        this.mensaje = json.eResponse.error;
      }
    },
    cancelar() {
      this.formVisible = false;
      this.listadoVisible = true;
      this.mensaje = '';
    },
    editar(item) {
      this.form = { ...item };
      this.formVisible = true;
      this.listadoVisible = false;
      this.mensaje = '';
    },
    async cancelarConstancia(item) {
      if (!confirm('¿Está seguro de cancelar la constancia?')) return;
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          eRequest: {
            action: 'cancel',
            data: {
              axo: item.axo,
              folio: item.folio,
              motivo: 'Cancelada por usuario'
            }
          }
        })
      });
      const json = await res.json();
      if (json.eResponse.success) {
        this.mensaje = 'Constancia cancelada';
        this.listar();
      } else {
        this.mensaje = json.eResponse.error;
      }
    },
    async imprimir(item) {
      // Aquí se puede abrir una ventana PDF o similar
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          eRequest: {
            action: 'print',
            data: {
              axo: item.axo,
              folio: item.folio
            }
          }
        })
      });
      const json = await res.json();
      if (json.eResponse.success) {
        // Suponiendo que regresa una URL o base64 del PDF
        window.open(json.eResponse.data[0].pdf_url, '_blank');
      } else {
        this.mensaje = json.eResponse.error;
      }
    },
    async buscar() {
      // Implementar búsqueda avanzada si es necesario
      // Por ahora, recarga el listado
      this.listar();
    }
  }
};
</script>

<style scoped>
.dictamenusodesuelo-page {
  max-width: 1100px;
  margin: 0 auto;
  padding: 2rem;
}
.breadcrumb {
  margin-bottom: 1rem;
}
.actions {
  margin-bottom: 1rem;
}
.form-panel {
  background: #f9f9f9;
  padding: 1rem;
  border-radius: 6px;
  margin-bottom: 2rem;
}
.form-row {
  margin-bottom: 1rem;
  display: flex;
  align-items: center;
}
.form-row label {
  width: 180px;
  font-weight: bold;
}
.form-row input, .form-row select {
  flex: 1;
  padding: 0.5rem;
}
.listado-panel table {
  width: 100%;
  border-collapse: collapse;
}
.listado-panel th, .listado-panel td {
  border: 1px solid #ddd;
  padding: 0.5rem;
}
.listado-panel th {
  background: #f0f0f0;
}
.mensaje {
  margin-top: 1rem;
  color: #b00;
}
</style>
