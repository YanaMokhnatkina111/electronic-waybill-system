-- 1. Проверка, что водитель имеет роль 'driver'
CREATE OR REPLACE FUNCTION check_driver_role()
RETURNS TRIGGER AS $$
BEGIN
    IF (SELECT role FROM users WHERE id = NEW.user_id) != 'driver' THEN
        RAISE EXCEPTION 'Только водители могут создавать путевые листы';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_check_driver_role
BEFORE INSERT ON waybills
FOR EACH ROW
EXECUTE FUNCTION check_driver_role();

-- 2. Проверка доступности водителя и ТС 
CREATE OR REPLACE FUNCTION check_availability()
RETURNS TRIGGER AS $$
BEGIN
    -- Проверка водителя: не может быть другого созданного путевого листа на эту дату
    IF EXISTS (
        SELECT 1 FROM waybills w
        WHERE w.user_id = NEW.user_id
          AND w.id != COALESCE(NEW.id, -1)
          AND w.status = 'created'
          AND w.date = NEW.date
    ) THEN
        RAISE EXCEPTION 'Водитель уже имеет активный путевой лист на эту дату';
    END IF;
    
    -- Проверка ТС: не может быть другого созданного путевого листа на эту дату
    IF EXISTS (
        SELECT 1 FROM waybills w
        WHERE w.vehicle_id = NEW.vehicle_id
          AND w.id != COALESCE(NEW.id, -1)
          AND w.status = 'created'
          AND w.date = NEW.date
    ) THEN
        RAISE EXCEPTION 'Транспортное средство уже используется в активном путевом листе';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Триггер работает при INSERT и UPDATE (чтобы нельзя было изменить статус на created если уже есть активный)
CREATE TRIGGER trg_check_availability
BEFORE INSERT OR UPDATE ON waybills
FOR EACH ROW
WHEN (NEW.status = 'created')
EXECUTE FUNCTION check_availability();

-- 3. Автоматическое обновление closed_at при закрытии путевого листа
CREATE OR REPLACE FUNCTION update_closed_at()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status = 'closed' AND OLD.status != 'closed' THEN
        NEW.closed_at = CURRENT_TIMESTAMP;
    ELSIF NEW.status != 'closed' AND OLD.status = 'closed' THEN
        NEW.closed_at = NULL;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_closed_at
BEFORE UPDATE ON waybills
FOR EACH ROW
EXECUTE FUNCTION update_closed_at();

-- 4. Проверка логики закрытия
CREATE OR REPLACE FUNCTION validate_waybill_closure()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status = 'closed' AND OLD.status != 'closed' THEN
        IF NEW.odometer_end IS NULL THEN
            RAISE EXCEPTION 'Нельзя закрыть путевой лист без конечного показания одометра';
        END IF;
        
        IF NOT EXISTS (
            SELECT 1 FROM medical_checks 
            WHERE waybill_id = NEW.id AND passed = true
        ) THEN
            RAISE EXCEPTION 'Нельзя закрыть путевой лист без пройденного медосмотра';
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validate_waybill_closure
BEFORE UPDATE ON waybills
FOR EACH ROW
EXECUTE FUNCTION validate_waybill_closure();
